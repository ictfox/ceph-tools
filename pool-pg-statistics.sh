#!/bin/bash

tmpfile="/tmp/cephtmpfile"
for pool in $(ceph osd pool ls detail | grep -v -E 'snap|^$' | cut -d " " -f2-3 | sed -e 's/ /|/g') ;
do
    poolid=$(echo $pool | cut -d "|" -f1)
    poolname=$(echo $pool | cut -d "|" -f2 | sed -e "s/'//g")
    objects=$(rados df | grep "$poolname " | awk '{print $3}')
    #echo "$poolid, $poolname |$objects|"
    echo > $tmpfile-$poolname

    ls -d /var/lib/ceph/osd/ceph-*/current/$poolid.*_head > /dev/null 2>&1
    if [ $? -eq 0 ]; then
        pg_dirs=$(ls -d /var/lib/ceph/osd/ceph-*/current/$poolid.*_head | tail -10)
        for pg_dir in $pg_dirs; do
            dirfiles=`find $pg_dir -type f |wc -l`
            echo "$dirfiles in $pg_dir" >> $tmpfile-$poolname
        done
        avg=`grep "head" $tmpfile-$poolname | awk '{ sum += $1; n++ } END { if (n > 0) print sum / n; }'`
    else
        avg=0
    fi

    rm -f $tmpfile-$poolname
    echo -e "id=$poolid \tpool=$poolname \tobjects=$objects \tpg-avg-files=$avg"
done
