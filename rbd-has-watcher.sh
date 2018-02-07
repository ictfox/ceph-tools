#! /bin/bash

if [ $# -lt 1 ] || [ $# -gt 2 ]; then
    echo "Example: $0 <pool-name> yes	# Get pool images WITH wathers, default value"
    echo "         $0 <pool-name> no	# Get pool images WITHOUT wathers"
    exit 1
fi

pool=$1
option=$2
if [ $# -eq 1 ]; then
    option="yes"
fi

images=`rbd ls -p $pool`
if [ $option == "no" ]; then
    echo "-- Images WITHOUT watchers --"
else
    echo "-- Images WITH watchers --"
fi

for image in $images; do
    rbd status -p $pool $image | grep -w none > /dev/null
    result=$?
    if [ $option == "yes" ]; then
        if [[ $result -ne 0 ]]; then
            echo "$image"
        fi
    else
        if [[ $result -eq 0 ]]; then
            echo "$image"
        fi
    fi
done
