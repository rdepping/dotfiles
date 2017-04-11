#!/bin/bash

#-------------------------------------------------------------------------------
# This script pushes code from one repository to another via branches.
# The idea is that code is "released" from an origin repo to a "vendor import"
# branch in another repo and tagged approporiately.
#
#
# Assumptions:
# - credentials for git repo access are already in place
# - clone does not already exist in the working directory
#
# Future:
# - allow specificaiton of a different source branch or commit to release
# - specify the username and email address to use for the git operations
#-------------------------------------------------------------------------------
set -e

#¸
help()
#-------------------------------------------------------------------------------
{
    echo "-------------------------------------------------------------------------------"
    echo ""
    echo "./releaseCode.sh <srcrepo> <srcrelbranch> <destrepo> <destupstreambranch> "
    echo "              <tag> <annotate> <working_dir> <dry-run>"
    echo ""
    echo ""
    echo "Pushes a release from a branch on a source repo to a vendor import branch on a release repo."
    echo ""
    echo "-s --srcrepo <source git repo url>"
    echo "    Required. Specifies the source repository."
    echo ""
    echo "-r --srcrelbranch <source git repo release branch name>"
    echo "    Required. Specifies the branch to release via on the source repo."
    #echo ""
    #echo "-c --srccommit <SHA or branch>"
    #echo "    Optional. If present then this specific commit that is merged to the source repo release branch."
    #echo "              Default is master branch"
    echo ""
    echo "-d --destrepo <destination git repo url>"
    echo "    Required. Specifies the destination repository for the push."
    echo ""
    echo "-u --destupstreambranch <destination upstream branch>"
    echo "    Required. Specifies the destination branch for the push"
    echo ""
    echo "-t --tag <value>"
    echo "    Optional.  Specify the tag value. Default if not specified is 'BASELINE_<date/time stamp>_PUSHED_TO_<TARGET>'"
    echo ""
    echo "-a --annotate <text string>"
    echo "    Optional.  Specify the tag annotation value. Default is 'Baseline source release provided to <TARGET>.'"
    echo ""
    echo "-m --merge"
    echo "    Optional.  Post release - merge from release branch to master branch on the destination repository"
    echo "               WARNING: Does not handle merge conflicts. Any conflicts need to be resolved manually and then committed"
    echo ""
    echo "-w --dir <value>"
    echo "    Optional.  If present then script execution will run from this folder and repositories"
    echo "               will be cloned into this folder.  Otherwise it will run from the current"
    echo "               working directory."
    echo ""
    echo "--dry-run"
    echo "    Optional.  If present then the final push to remotes will not"
    echo "               occur and any other changes made by these scripts may be undone by deleting"
    echo "               the relevant directories."
    echo ""
    echo "-f --force"
    echo "    Optional.  If present then script will auto-confirm all actions"
    echo ""
    echo "-------------------------------------------------------------------------------"
    echo "Example:"
    echo ""
    echo "[1] ./releaseCode.sh -s ssh://git@somerepo.git -r someRepo/release -d ssh://git@someOtherRepo.git -u someRepo/upstream"
    echo "           - This will clone the source repo to be pushed to the target repo to the current directory"
    echo "             and..."
    echo "               - checkout release branch"
    echo "               - merge from the HEAD of master branch to release branch on the source repo"
    echo "               - tag the HEAD of the release branch with ..."
    echo "                   - tag 'BASELINE_<date/time stamp>_PUSHED_TO_<TARGET>'"
    echo "                   - annotation 'Baseline source release provided to <TARGET>.'"
    echo "               - push release branch back to source (remote) repo"
    echo "               - push release branch to target branch on target repo"
    echo ""
    echo "-------------------------------------------------------------------------------"
}

#-------------------------------------------------------------------------------
function printnexec
#-------------------------------------------------------------------------------
{
    printf "\n----- '%s'" "${*}"
    printf "\n"
    "${*}"
}

#-------------------------------------------------------------------------------
function continue_exec
#-------------------------------------------------------------------------------
{
  if [ $AUTO_CONFIRM -eq 1 ]
  then
    return 0
  else
    read from_stdin
    export user_resp
    user_resp=`echo ${from_stdin[0]} | tr '[:lower:]' '[:upper:]'`
    if [ "${user_resp}" != "Y" ]
    then
        if [[ -z $1 ]] && [[ $1 != "1" ]]
        then
            printf "\n\n"
            exit
        fi
    fi
  fi
}

#-------------------------------------------------------------------------------
function missing_param
#-------------------------------------------------------------------------------
{
  printf "\n\nERROR: Missing Required Parameter: $1\n\n"
  help
  exit
}

#===============================================================================
# Main Body
#===============================================================================

unset TAG
unset SOURCE_REPO_CHECKOUT
unset ANNOTATION
unset WORKING_DIR
unset PUSH2ORIGIN
unset PUSH2DESTINATION
unset SOURCE_REPO_URL
unset SOURCE_REL_BRANCH_NAME
unset DEST_REPO_URL
unset DEST_UPSTREAM_BRANCH_NAME
unset FORCEPUSHDEST
unset AUTO_CONFIRM
unset DEST_MERGE_TO_MASTER

export AUTO_CONFIRM=0

#-------------------------------------------------------------------------------
# By default, we'll push to both origin and destination repositories
#-------------------------------------------------------------------------------
export PUSH2ORIGIN=1
export PUSH2DESTINATION=1

#-------------------------------------------------------------------------------
# Check for input parameters.
#-------------------------------------------------------------------------------

if [ $# -gt 0 ]
then
    for ((i = 0; $# > 0; i++))
    do
        case $1 in
            -s|--srcrepo)
                shift
                export SOURCE_REPO_URL="$1"
                shift
                ;;
            # TODO: this needs to be added in and properly supported
            # -c|--srccommit)
            #     shift
            #     export SOURCE_REPO_CHECKOUT="$1"
            #     shift
            #     ;;
            -r|--srcrelbranch)
                shift
                export SOURCE_REL_BRANCH_NAME="$1"
                shift
                ;;
            -d|--destrepo)
                shift
                export DEST_REPO_URL="$1"
                shift
                ;;
            -u|--destupstreambranch)
                shift
                export DEST_UPSTREAM_BRANCH_NAME="$1"
                shift
                ;;
            -t|-tag)
                shift
                export TAG="$1"
                shift
                ;;
            -a|--annotate)
                shift
                export ANNOTATION="$1"
                shift
                ;;
            -w|--dir)
                shift
                export WORKING_DIR="$1"
                shift
                ;;
            -f|--force)
                export AUTO_CONFIRM=1
                shift
                ;;
            --dry-run)
                export PUSH2ORIGIN=0
                export PUSH2DESTINATION=0
                shift
                ;;
            -h|--help)
                help
                exit
                ;;
            -p)
            # Undocumented force push to destination
                export FORCEPUSHDEST=1
                shift
                ;;
            -m|--merge)
                export DEST_MERGE_TO_MASTER=1
                shift
                ;;
            *)
                printf "\n\nERROR: Unexpected Parameter: %s\n\n" "$1"
                help
                exit
                ;;
        esac
    done
fi

#-------------------------------------------------------------------------------
# validate input parameters
#-------------------------------------------------------------------------------

if [[ -z ${SOURCE_REPO_URL} ]]
then
  missing_param '--srcrepo'
else
  filename="${SOURCE_REPO_URL##*/}"
  export SOURCE_REPO_NAME="${filename%.*}"
fi

if [[ -z ${DEST_REPO_URL} ]]
then
  missing_param '--destrepo'
else
  filename="${DEST_REPO_URL##*/}"
  export DEST_REPO_NAME="${filename%.*}"
fi

if [[ -z ${SOURCE_REPO_CHECKOUT} ]]
then
    export SOURCE_REPO_CHECKOUT="master"
fi

if [[ -z ${SOURCE_REL_BRANCH_NAME} ]]
then
  missing_param '--srcrelbranch'
fi

if [[ -z ${TAG} ]]
then
  datestamp=`date +%Y.%m.%d-%H.%M.%S`
  export TAG
  TAG=`printf "BASELINE_%s_PUSHED_TO_<TARGET>" "${datestamp}"`
fi

if [[ -z ${ANNOTATION} ]]
then
    export ANNOTATION="Baseline source release provided to <TARGET>."
fi

if [[ -z ${WORKING_DIR} ]]
then
    export WORKING_DIR
    WORKING_DIR=`pwd`
fi

if [[ -z ${DEST_UPSTREAM_BRANCH_NAME} ]]
then
  missing_param '--destupstreambranch'
fi

if [[ -z ${FORCEPUSHDEST} ]]
then
    export FORCEPUSHDEST=0
fi

if [[ -z ${DEST_MERGE_TO_MASTER} ]]
then
    export DEST_MERGE_TO_MASTER=0
fi

cd "${WORKING_DIR}"

#-------------------------------------------------------------------------------
# Display parameter settings in use so user can decide to continue with same or not.
#-------------------------------------------------------------------------------

printf "\n\n"
printf "\n#####################################################################"
printf "\n#"
printf "\n#       Source repo:               %s" "${SOURCE_REPO_URL}"
printf "\n#       Source repo rel branch:    %s" "${SOURCE_REL_BRANCH_NAME}"
printf "\n#       Tag:                       %s" "${TAG}"
printf "\n#       Annotation:                %s" "${ANNOTATION}"
printf "\n#       Dest repo:                 %s" "${DEST_REPO_URL}"
printf "\n#       Dest repo target branch:   %s" "${DEST_UPSTREAM_BRANCH_NAME}"
printf "\n#       Working Directory:         %s" "${WORKING_DIR}"
printf "\n#       Push to origin remote:     %s" "${PUSH2ORIGIN}"
printf "\n#       Push to target remote:     %s" "${PUSH2DESTINATION}"
printf "\n#"
printf "\n#       Time:                      %s" "`date`"
printf "\n#"
printf "\n#####################################################################"
printf "\n\n"

#-------------------------------------------------------------------------------
# Check if clone already exists
#-------------------------------------------------------------------------------

chk4dir=`printf "./%s" "${SOURCE_REPO_NAME}"`

if [ ! -d ${chk4dir} ]
then
    printf "\nDirectory not found:  '%s'" "${chk4dir}"
    printf "\n\n"
    printnexec git clone ${SOURCE_REPO_URL}
    cd ${SOURCE_REPO_NAME}
else
    printf "\nDirectory found:      '%s'" "${chk4dir}"
    printf "\n\n"
    printf "\tError: A copy of the repository already exists in '%s'. \n\t\tPlease delete it or specify a clean directory using the -w option. \n" "${WORKING_DIR}"
    exit
fi

printf "\n\n"

printf "\n--------------------------------------------------------------------------------\n"

release_tag=${TAG}
release_tag_annotation=`printf "%s" "${ANNOTATION}"`

# TODO: this sha print should take account of the value of SOURCE_REPO_CHECKOUT
printf "\n--------------------------------------------------------------------------------\n\n"
sha=`git log --date-order --pretty=oneline --no-abbrev-commit --max-count=1 | cut -d " " -f 1`
printf "\n\nThe SHA1 for this release is:\n"
printf "\n\t%s: '%s'" "${SOURCE_REPO_NAME}" "${sha}\n"


if [ $AUTO_CONFIRM -eq 0 ]
then
    printf "\n\n"
    printf "Do you wish to continue? (Y/N) > "
    continue_exec
fi
printf "\n--------------------------------------------------------------------------------\n\n"

git checkout -B ${SOURCE_REL_BRANCH_NAME}
git status

git merge --verbose --no-ff "${SOURCE_REPO_CHECKOUT}"

merge_sha=`git log --date-order --pretty=oneline --no-abbrev-commit --max-count=1 | cut -d " " -f 1`

git tag -a ${release_tag} -m "${release_tag_annotation}"  ${merge_sha}

printf "\n--------------------------------------------------------------------------------\n\n"


printf "\n\n"
printf "\n\t+--------------------------------------------------------------------"
printf "\n\t|       Repository: %s" "${SOURCE_REPO_NAME}"
printf "\n\t+--------------------------------------------------------------------"
printf "\n\n"

git status
git --no-pager log --graph --decorate=full --color=auto --date-order --max-count=4


if [ $AUTO_CONFIRM -eq 0 ]
then
    printf "\n\n"
    printf "\n\nThe above is what will be pushed to the source and target remote repositories."
    printf "\nDo you wish to continue? (Y/N) > "
    continue_exec
fi

printf "\n\n"
printf "\n#####################################################################"
printf "\n#"
printf "\n#       Push to SOURCE repo: %s" "${release_tag}"
printf "\n#       Time:           %s" "`date`"
printf "\n#"
printf "\n#####################################################################"
printf "\n\n"

if [ $PUSH2ORIGIN -eq 1 ]
then
    printf "\n\tgit push -u --tags --verbose origin %s" "${SOURCE_REL_BRANCH_NAME}"
    git push -u --tags --verbose origin ${SOURCE_REL_BRANCH_NAME}
else
    printf "\nDry run selected so push to target remote repository '%s' will not be done." "${SOURCE_REPO_NAME}"
    printf "\nUse the following command from the current folder (%s) if you wish to execute the push." "`pwd`"
    printf "\n\tgit push -u --tags --verbose origin '%s'" "${SOURCE_REL_BRANCH_NAME}"
    printf "\n\n"
    git push -u --tags --verbose --dry-run origin ${SOURCE_REL_BRANCH_NAME}
fi

printf "\n\n"
printf "\n#####################################################################"
printf "\n#"
printf "\n#       Push to DESTINATION repo: %s" "${release_tag}"
printf "\n#       Time:        %s" "`date`"
printf "\n#"
printf "\n#####################################################################"
printf "\n\n"

# FIXME - a very clunky way of checking that the destination remote is added...
# plus we always do a fresh clone now, so the destination will never be set in advance
destination_remote_added=`git remote -v | grep "destination" | grep "${DEST_REPO_URL}" | wc -l`

if [ $destination_remote_added -ne 2 ]
then
    printf "\n\n---- 'git remote add destination %s'\n" "${DEST_REPO_URL}"
    git remote add destination ${DEST_REPO_URL}
    git fetch destination
    printf "\n\n"
fi

if [ $PUSH2DESTINATION -eq 1 ]
then
  if [ $FORCEPUSHDEST -eq 0 ]
    then
      printf "\n\tgit push --tags --verbose destination HEAD:%s" "${DEST_UPSTREAM_BRANCH_NAME}"
      printf "\n\n"
      git push --tags --verbose destination HEAD:${DEST_UPSTREAM_BRANCH_NAME}
    else
      printf "WARNING: FORCE PUSH TO DESTINATION SET - Do you wish to continue? (Y/N) > "
      continue_exec
      printf "\n\tgit push -f --tags --verbose destination HEAD:%s" "${DEST_UPSTREAM_BRANCH_NAME}"
      printf "\n\n"
      git push -f --tags --verbose destination HEAD:${DEST_UPSTREAM_BRANCH_NAME}
    fi
else
    printf "\nDry run selected so push to remote repository '%s' will not be done." "${DEST_REPO_URL}"
    printf "\nUse the following command from the current folder (%s) if you wish to execute the push." "`pwd`"
    printf "\n\tgit push --tags --verbose destination destination/%s" "${DEST_UPSTREAM_BRANCH_NAME}"
    printf "\n\n"
    git push --tags --verbose --dry-run destination HEAD:${DEST_UPSTREAM_BRANCH_NAME}
fi

if [ $DEST_MERGE_TO_MASTER -eq 1 ]
then
  export GIT_MERGE_AUTOEDIT=no
  cd ..
  printf "\nCheking out destination repo '%s'" "${DEST_REPO_URL}"
  printnexec git clone ${DEST_REPO_URL} destinationRepo
  cd destinationRepo
  printnexec git checkout "${DEST_UPSTREAM_BRANCH_NAME}"
  printnexec git checkout master
  printf "\nMerge to master from '%s'" "${DEST_UPSTREAM_BRANCH_NAME}"
  printnexec git merge --no-ff --verbose "${DEST_UPSTREAM_BRANCH_NAME}"
  if [ $PUSH2DESTINATION -eq 1 ]
    then
      printf "\nPush master branch to remote repo"
      printnexec git push
    else
      printf "\nDry run selected so push of master to remote repository '%s' will not be done." "${DEST_REPO_URL}"
    fi
else
  printf "\nNot merging '%s' to master on the destination repository" "${DEST_UPSTREAM_BRANCH_NAME}"
fi
