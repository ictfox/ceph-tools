#! /bin/bash

monid=$1

if [ $# -lt 1 ]; then
    echo "example: $0 [mon_id]"
    exit 1
fi

systemctl stop ceph-mon@$monid.service
ceph mon remove $monid

#Remove the monitor entry from ceph.conf
