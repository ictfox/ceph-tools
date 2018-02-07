#! /bin/bash

if [ $# -gt 1 ]; then
    echo "Example: $0           # restart all osds"
    echo "         $0 <osdid>   # restart specified osd>"
    exit 1
fi

function restart_osd()
{
    id=$1
    echo "restart osd: $id"
    systemctl restart ceph-osd@$id.service

    while [ 1 ]; do
        ceph -s | grep "objects degraded" > /dev/null
        if [[ $? -ne 0 ]]; then
            break
        fi
        sleep 5
    done
}

if [ $# -eq 1 ]; then
    sosdid=$1
    restart_osd $sosdid
else
    osdids=`df -h | grep osd | awk '{print $NF}' | awk -F '[-]' '{print $2}'`
    for osdid in $osdids ; do
        restart_osd $osdid
    done
fi

