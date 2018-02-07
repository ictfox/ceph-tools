#! /bin/bash

pool=$1
list=`rados -p $pool ls`

if [ $# -lt 1 ]; then
    echo "example: $0 [pool name] | column -t"
    exit 1
fi

(
echo "object size_keys(kB) size_values(kB) total(kB) nr_keys nr_values"
for obj in $list; do
    echo -en "$obj ";
    rados -p $pool listomapvals $obj | awk '
    /^key: \(.* bytes\)/ { sizekey+= substr($2, 2, length($2)); nbkeys++ }
    /^value: \(.* bytes\)/ { sizevalue+= substr($2, 2, length($2)); nbvalues++ }
    END { printf("%i %i %i %i %i\n", sizekey/1024, sizevalue/1024, (sizekey+sizevalue)/1024, nbkey, nbvalues) }
    '
done
)
