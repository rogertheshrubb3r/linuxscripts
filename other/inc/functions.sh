#!/bin/sh

#From: "Grigoriy Strokin" <grg@philol.msu.ru>
#Newsgroups: comp.unix.shell
#Subject: fast basename and dirname functions for BASH/SH
#Date: Sat, 27 Dec 1997 21:18:40 +0300
#
#Please send your comments to grg@philol.msu.ru

function myname() {
  local name="${1##*/}"; echo "${name%$2}"
}

function dirname() {
  local dir="${1%${1##*/}}"
  [ "${dir:=./}" != "/" ] && dir="${dir%?}"
  echo "$dir"
}

# Two additional functions:
# 1) namename prints the basename without extension
# 2) ext prints extension of a file, including "."

function namename() {
  local name=${1##*/}; local name0="${name%.*}"; echo "${name0:-$name}"
}

function ext() {
  local name=${1##*/}; local name0="${name%.*}"
  local ext=${name0:+${name#$name0}}
  echo "${ext:-.}"
}

catm () {
# cat/zcat/bzcat multiple files IN GIVEN ORDER
# !!! create temp. file
local TMPFILE
local FILES
TMPFILE=`mktemp -t catm.XXXXXX` || TMPFILE=`tempfile -p catm`

    for i in "$@"; do
    if [ -f $i ]; then
	iext=`ext $i`
	if [ "$iext" == ".gz" ]; then
            zcat $i	>> $TMPFILE
        elif [ "$iext" == ".bz2" ]; then
	    bzcat $i	>> $TMPFILE
        else
	    cat $i	>> $TMPFILE
        fi
    fi
    done;
    cat $TMPFILE
    rm -f $TMPFILE
}

grepm () {
# cat/zcat/bzcat multiple files IN GIVEN ORDER
# usage: grepm [-i] [-o order] -e <EX> file(s)
# -i = case insensitive
# -o	list order (t=by time, 
# create temp. file
local TMPFILE=
local EX
local FILES
TMPFILE=`mktemp -t grepm.XXXXXX` || TMPFILE=`tempfile -p grepm`
[ -f $TMPFILE ] || TMPFILE="/tmp/grepm.tmp"
    while [ $# -gt 0 ]; do
      case "$1" in
       -e) EX="$2" ; shift 2;;
	-i) OPTS=-i; shift ;;
	-o) ORD=$2; shift 2 ;;
       *) FILES="$FILES $1"; shift;
      esac
    done

#    FILES=`ls -1 $FILES`

    for i in $FILES; do
#	echo "i=$i"
    if [ -f "$i" ]; then
	iext=`ext $i`
	case $iext in
	.gz|.GZ|.tgz|.TGZ)
	    zgrep $OPTS $EX $i	>> $TMPFILE ;;
	.bz|.bz2|.BZ|.BZ2|.tbz|.TBZ|.tbz2|.TBZ2) 
	    bzgrep $OPTS $EX $i	>> $TMPFILE ;;
	*)
	    grep $OPTS $EX $i	>> $TMPFILE ;;
	esac
    fi
    done
    cat $TMPFILE
    rm -f $TMPFILE
}
