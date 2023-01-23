nflag=0
vlevel=0
OUT=
while [ $# -gt 0 ]; do
  case "$1" in 
   -o ) OUT=$2 ; shift 2 ;;
   -n ) nflag=1 ; shift ;;
   -l | -v ) vlevel=$(( vlevel+1 )) ; shift ;;
   -ver* ) echo "Version $version"  ; exit 1 ;;
   * ) echo "Saw non flag $arg" ; break ;;
  esac
done

echo "OUTFILE: $OUT"
