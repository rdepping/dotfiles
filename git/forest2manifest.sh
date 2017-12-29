#!/bin/bash

if [ -z "$1" ]; then
    top=`pwd`
else
    top=$1
fi

gitdirs=`cd $top; find . -type d -name .git`
repos=""
for g in $gitdirs; do
    repos="$repos `dirname $g`"
done
repos=`echo $repos | sort`

remotes=""
for repo in $repos; do
    url=`git config -f $repo/.git/config --get remote.origin.url`
    scheme=`echo $url | sed 's;://.*;;'`
    host=`echo $url | awk -F: '{print $2}' | sed 's;//;;' | sed 's;/.*;;'`
    remote="$scheme://$host"
    if [[ $remotes != *"$remote"* ]]; then
        remotes="$remotes $remote"
    fi
done

remotes=`echo $remotes | sort`

cat >default.xml <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<manifest>
EOF

for remote in $remotes; do
    rname=`echo $remote | sed 's;.*://;;'`
    cat >>default.xml <<EOF
    <remote name="$rname" fetch="$remote" />
EOF
done

cat >>default.xml <<EOF

    <default remote="github.com" revision="master" sync-j="2"/>

EOF

for repo in $repos; do
    url=`git config -f $repo/.git/config --get remote.origin.url`
    scheme=`echo $url | sed 's;://.*;;'`
    host=`echo $url | awk -F: '{print $2}' | sed 's;//;;' | sed 's;/.*;;'`
    remote="$scheme://$host"
    rname=`echo $remote | sed 's;.*://;;'`
    name=`echo $url | awk -F: '{print $2}' | sed 's;//;;' | sed 's;[^/]*/;;'`
    clonepath=`echo $repo | sed "s;$(pwd)/;;"`
    cat >>default.xml <<EOF
    <project remote="$rname" name="$name" path="$clonepath" />
EOF
done

cat >>default.xml <<EOF
</manifest>
EOF

