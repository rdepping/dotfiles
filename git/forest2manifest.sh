#!/bin/bash

# Script to walk a tree of Git clones and build an XML manifest
# for use with the git-repo tool.
#
# Parameters (all optional):
#  1: path to manifest file to write (default: ./default.xml).
#  2: path to the root of the Git clone tree (default: current directory).
#  3: default Git remote for the repo manifest (default: first found in the tree of Git clones).

if [ -z "$1" ]; then
    mfile="default.xml"
else
    mfile=$1
fi

if [ -z "$2" ]; then
    top=`pwd`
else
    top=$2
fi

if [ -z "$3" ]; then
    defremote="github.com"
else
    defremote=$3
fi

gitdirs=`cd $top; find . -not -path \*/.repo/\* -type d -name .git`
repos=""
for g in $gitdirs; do
    repos="$repos `dirname $g`"
done
repos=`echo $repos | tr ' ' '\n' | sort | tr '\n' ' '`

remotes=""
for repo in $repos; do
    url=`git config -f $top/$repo/.git/config --get remote.origin.url`
    scheme=`echo $url | sed 's;://.*;;'`
    host=`echo $url | awk -F: '{print $2}' | sed 's;//;;' | sed 's;/.*;;'`
    remote="$scheme://$host"
    if [[ $remotes != *"$remote"* ]]; then
        remotes="$remotes $remote"
    fi
done

remotes=`echo $remotes | sort`

if [ ${#remotes[@]} -eq 1 ]; then
    defremote="${remotes[0]}"
    defremote=`echo $defremote | awk -F: '{print $2}' | sed 's;//;;' | sed 's;[^/]*/;;'`
fi

cat >$mfile <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<manifest>
EOF

for remote in $remotes; do
    rname=`echo $remote | sed 's;.*://;;'`
    cat >>$mfile <<EOF
    <remote name="$rname" fetch="$remote" />
EOF
done

cat >>$mfile <<EOF
    <default remote="$remote" revision="master" sync-j="2"/>
EOF

for repo in $repos; do
    url=`git config -f $top/$repo/.git/config --get remote.origin.url`
    scheme=`echo $url | sed 's;://.*;;'`
    host=`echo $url | awk -F: '{print $2}' | sed 's;//;;' | sed 's;/.*;;'`
    remote="$scheme://$host"
    rname=`echo $remote | sed 's;.*://;;'`
    name=`echo $url | awk -F: '{print $2}' | sed 's;//;;' | sed 's;[^/]*/;;'`
    clonepath=`echo $repo | sed "s;$(pwd)/;;" | sed "s;./;;"`
    cat >>$mfile <<EOF
    <project remote="$rname" name="$name" path="$clonepath" />
EOF
done

cat >>$mfile <<EOF
</manifest>
EOF

