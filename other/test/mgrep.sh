


#!/bin/bash
[ $# -lt 2 ] && \
  { echo "Usage: $0 \"quoted list of strings to match\" [files]..."; exit; }
names=$1
shift
foobar=$*
for i in $names ; do
  foobar=`grep -l $i $foobar` || exit
done
echo $foobar | tr \  \\n
