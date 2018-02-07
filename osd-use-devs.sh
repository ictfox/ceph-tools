#! /bin/bash

if [ $# -gt 1 ]; then
    echo "Example: $0         	# Get all OSDs devices relationship"
    echo "         $0 <osd-id>  # Get specified OSD device relationship"
    exit 1
fi

if [ $# -eq 1 ]; then
    option="notall"
    osdid=$1
else
    option="all"
fi

echo -e "OSD \tFilestore \t Journal \t Journal-Size"

if [ $option == "all" ]; then
    infos=`df | grep osd | awk '{print $1,$6}'`
else
    infos=`df | grep osd | grep -w "ceph-$osdid" | awk '{print $1,$6}'`
fi

IFS=$'\n'
for info in $infos; do
    fdev=`echo $info | awk '{print $1}'`
    jpath=`echo $info | awk '{print $2}'`
    osdid=`echo $jpath | awk -F '[-]' '{print $2}'`

    jfile="$jpath/journal"
    if [ -L "$jfile" ]; then
        tmpvalue=`ls -l $jfile | awk '{print $NF}'`
        echo $tmpvalue | grep "partuuid" > /dev/null
        result=$?
        if [[ $result -eq 0 ]]; then
            jdev=`ls -l $tmpvalue | awk '{print $NF}'`
            jsize=`fdisk -l $tmpvalue | grep -w "Disk" | awk -F '[ ,]' '{print $3,$4}'`
        else
            jdev="Link:$tmpvalue"
            jsize="/"
        fi
    elif [ -f "$jfile" ]; then
        jdev="File:journal"
        jsize=`du -h $jfile | awk '{print $1}'`
    fi
    echo -e "$osdid \t$fdev \t$jdev \t$jsize"
done
