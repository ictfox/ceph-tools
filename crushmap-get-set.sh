#! /bin/bash

function usage()
{
    echo "usage: $0 get/set"
}

arg=$1

## Main
if [[ $arg == "get" ]] ; then
    ceph osd getcrushmap -o crushmap
    crushtool -d crushmap -o crush.map
elif [[ $arg == "set" ]] ; then
    crushtool -c crush.map -o crushmap
    ceph osd setcrushmap -i crushmap
else
    usage
fi
