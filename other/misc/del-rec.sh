#!/bin/sh
# kidd: recursively delete files

delfiles() {
    [ $1 ] && cd $1 && echo "entering: $i"
    for i in `ls -1R`; do 
	[ -d $i ] && delfiles $i
	[ -f $i ] && rm $i && echo "removing: $i"
    done
}

delfiles $@
