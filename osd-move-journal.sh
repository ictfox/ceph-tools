#!/bin/bash
osd_id=$1
jnl_old_path=$2
jnl_new_path=$3

if [ $# -lt 3 ]; then
    echo "example: $0 [osd_id] [jnl_old_path] [jnl_new_path]"
    exit 1
fi

systemctl stop ceph-osd@$osd_id.service
ceph-osd --flush-journal -i $osd_id
sleep 2

mv $jnl_old_path $jnl_new_path
ln -s $jnl_new_path /var/lib/ceph/osd/ceph-$osd_id/journal
sleep 3
systemctl start ceph-osd@$osd_id.service
echo "****new journal path info:****"
ll /var/lib/ceph/osd/ceph-$osd_id/journal
