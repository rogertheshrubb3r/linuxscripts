#!/bin/sh

newfile=test.diff

iidx=0; ridx=0
cat $newfile | while read line; do
    type=`echo $line | awk '{print $1}'`; package=`echo $line | awk '{print $2}'`; status=`echo $line | awk '{print $3}'`
    if [ "$type" == ">" ]; then # package installed
	installed[$iidx]="$package (previous status: $status)"
	echo found installed
	echo "iidx=$iidx; ${installed[$iidx]}; ${#removed[@]}"
	let "iidx = $iidx + 1"
    elif [ "$type" == "<" ]; then # package deleted
	removed[$ridx]="$package (previous status: $status)"
	echo found removed
	echo "ridx=$ridx; ${removed[$iidx]}; "
	let "ridx = $ridx + 1"
    fi
done


idx=0; elems=${#removed[@]};
echo "Removed packages: [$elems]"
while [ "$idx" -lt "$elems" ]
do    # List all the elements in the array.
  echo "  ${removed[$idx]}"
  let "idx = $idx + 1"
done

idx=0; elems=${#installed[@]};
echo "Installed packages: [$elems]"
while [ "$idx" -lt "$elems" ]
do    # List all the elements in the array.
  echo "  ${installed[$idx]}"
  let "idx = $idx + 1"
done

echo ""


exit 1


a[0]="abc"

i=0

a[$i]="def"

a[1]="ghi"

echo ${a[$i]}

