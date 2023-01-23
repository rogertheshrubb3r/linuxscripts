#!/bin/sh

echoArgs () { 
    echo $#
    n=0;
    for i in "$@"; do
#	n=`echo $n+1|bc -l`
        echo "arg $n: ($i)";
    done;
    n=0;
    for i in $*; do
#	n=`echo $n+1|bc -l`
        echo "arg $n: (($i))";
    done
}


echoArgs $@
