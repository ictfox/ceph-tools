#! /bin/bash

pool=$1
image=$2
snap=$3

if [ $# -lt 1 ] || [ $# -gt 3 ]; then
    echo "Example: $0 <pool-name>"
    echo "         $0 <pool-name> <image-name>"
    echo "         $0 <pool-name> <image-name> [snap-name]   # --from-snap"
    exit 1
fi

if [ $# -eq 1 ]; then
    images=`rbd ls -p $pool`
    file=$pool.rbd-size
    echo > $file
    for image in $images; do
        size=`rbd diff -p $pool $image | awk '{ SUM += $2 } END { print SUM/1024/1024 " MB" }'`
        echo -e "$image \t $size" >> $file
    done
    cat $file | awk '{print $2,$3,$1}' | sort -gr | column -t > $file.sort
elif [ $# -eq 2 ]; then
    size=`rbd diff -p $pool $image | awk '{ SUM += $2 } END { print SUM/1024/1024 " MB" }'`
    echo -e "$pool/$image \t $size"
else
    size=`rbd diff -p $pool $image --from-snap $snap | awk '{ SUM += $2 } END { print SUM/1024/1024 " MB" }'`
    echo -e "$pool/$image --from-snap $snap \t $size"
fi
