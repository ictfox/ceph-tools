#! /bin/bash

osdid=$1

if [ $# -lt 1 ]; then
    echo "example: $0 [osd_id]"
    exit 1
fi

systemctl stop ceph-osd@$osdid.service
ceph osd down $osdid
ceph osd crush remove osd.$osdid
ceph auth del osd.$osdid
ceph osd rm $osdid

umount /var/lib/ceph/osd/ceph-$osdid
