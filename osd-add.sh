#! /bin/bash

osdid=$1
bucket=$2
weight=$3
osd_dev=$4

if [ $# -lt 3 ]; then
    echo "example: $0 [osd_id] [in which bucket] [osd weight]"
    echo "         $0 [osd_id] [in which bucket] [osd weight] [device]"
    exit 1
fi

echo "$osdid, $bucket, $weight, $osd_dev"
if [[ $osdid != "" ]]; then
    mkdir -p /var/lib/ceph/osd/ceph-$osdid
    mkfs.xfs $osd_dev
    mount -o rw,noatime,inode64,logbsize=256k,delaylog $osd_dev /var/lib/ceph/osd/ceph-$osdid

    ceph-osd -i $osdid --mkfs --mkkey
fi

ceph auth add osd.$osdid osd 'allow *' mon 'allow rwx' -i /var/lib/ceph/osd/ceph-$osdid/keyring
systemctl start ceph-osd@$osdid.service
ceph osd crush add $osdid $weight host=$bucket
