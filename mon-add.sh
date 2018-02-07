#! /bin/bash

monid=$1
monip=$2

monmap=/tmp/monmap
monkeyring=/tmp/mon-keyring

if [ $# -lt 2 ]; then
    echo "example: $0 [mon_id] [mon_ip]"
    exit 1
fi

mkdir /var/lib/ceph/mon/ceph-$monid
mkdir -p /tmp

ceph auth get mon. -o $monkeyring
ceph mon getmap -o $monmap

ceph-mon -i $monid --mkfs --monmap $monmap # --keyring $monkeyring
ceph-mon -i $monid --public-addr $monip

#add the monitor entry to ceph.conf
