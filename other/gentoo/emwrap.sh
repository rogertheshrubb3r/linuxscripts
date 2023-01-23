#!/bin/bash 

# Date 6-29-05 removed linux26 
# Date 6-24-05 Removed the "v" option to emerge, and added clean_up to remove dir created by 
# Date 6-14-05 Version 3.0.2 fix function clean to clean up failed and sys list. Also added 
# gcc-config and binutils-config to tc_filter. 
# 
# Use at yee own risk. It works for me, but then I wrote it. 
# 
# Toolchain thang 
# emerge linux-headers glibc && emerge glibc binutils gcc && emerge binutils gcc 
#    
# Thanks to ecatmur's dep script, gentoo forums, for help_fmt and print_help 
# The build script for the edited wrld.lst-->build.lst. Anything that fails to 
#  emerge is copied to failed.lst  To view the build.lst or failed.lst use 
#  "less failed.lst" or your favorite pager. 
# Version 2.0.5 , 3-30-05 
# Vwesion 3.0.6 , 12-15-05 Added saveing of the failed.lst to be 
# saved to roots dir. Cleaned up and fixed formating. 

PROG="emwrap.sh" 
VERSION="3.0.6" 
TAG="cats is rats mit fuzzy tails" 
DESC="A wrapper for emerge to controll toolchain updates" 

function colors(){ 
   if [[ $nc != "yes" ]]; then 
   #Set up colors 
   NO=$'\x1b[0;0m' 
   BR=$'\x1b[0;01m' 
   RD=$'\x1b[31;01m' Rd=$'\x1b[00;31m' 
   GR=$'\x1b[32;01m' Gr=$'\x1b[00;32m' 
   YL=$'\x1b[33;01m' Yl=$'\x1b[00;33m' 
   BL=$'\x1b[34;01m' Bl=$'\x1b[00;34m' 
   FC=$'\x1b[35;01m' Fc=$'\x1b[00;35m' 
   CY=$'\x1b[36;01m' Cy=$'\x1b[00;36m' 
   COLUMNS=${COLUMNS:-80} 
   spaces=$(for ((i=0;i<COLUMNS;++i)); do echo -n " "; done) 
   fi 
} 

help_fmt(){ 
   sed -r "s/( |^)$PROG( |$)/$CY\\0$NO/ 
   s/^[^[:space:]].*:/$YL\\0$NO/ 
   s/[[:space:]]-[][[:alpha:]?-]+/${FC}\\0${NO}/g 
   s/[[:upper:]_]{3,}/${RD}\\0${NO}/g 
   s/\\(default\\)/${BR}\\0${NO}/ 
   s:( |^)/[^[:space:]]+:$GR\\0$NO: 
   s/^(An? [[:alpha:]]+ is )([[:alpha:]]+)/\\1${BR}\\2${NO}/" 
} 

print_help(){ 
      cat <<END #|help_fmt 
    
      ${GR}${PROG}  v. ${VERSION} ${BL}"${TAG}"${NO} 
      ${GR}${DESC}!${NO} 

Usage: ${PROG} [OPTION] 

Date 4-23-05 
Use at yee own risk. It works for me, but then I wrote it. 
A wrapper to run emerge. It checks if the ToolChain is schedualed to be updated and 
if so, you can rebuild the toolchain. It uses an edited world/system -uD/e generated 
list with the toolchain items removed to emerge the rest of the files as if you had 
done a normal "emerge system/world -uD/e". 

This wrapper can do 3 things for you: 
1. Test if there is a toolchain, TC, update in "emerge system/world -uD". 
2. If there is and you want to then you can rebuild your TC and then using an 
   edited list to build the other items scheduled to be updated. 
3. Do the update without updating the TC, toolchain. 
  
The flags are chainable and change whether your doing a system or world emerge and 
from -uD to -e, --emptytree. There is also a pretend mode, -p. Like emerge -p it 
shows you what will be emerged. I recomemnd that instead of boldy going forth, add 
the -p to the end of the switchs first, to see whats going to be emerged. Then you 
can remove it. 

Example emwrap.sh -sep ==> emerge system --emptytree -pretend. If you remove the -p it 
will do a build of all packages in system except for the TC. " emwrap.sh -set or -wet " 
updates the entire TC. If the -b switch is used instead of -t then the entire TC is built 
and then all system packages minus the files that comprise the toolchain. 

   Here are the TC build list used in this wraper when doing updates. 
If linux-headers    TC="linux-headers glibc $tc_conf binutils gcc glibc binutils gcc" 
If glibc            TC_glb="glibc $tc_conf binutils gcc glibc binutils gcc" 
If binutils or gcc  TCmini="$tc_conf binutils gcc binutils gcc" 

Note as of Version 2.0.5 binutils-config and gcc-config are updated with the TC update. 

   The TC build sripts are basicly fall through. If you have a linux-headers update 
   then the srcipt will use TC, if its a glibc update then TC_glib and 
   if binutils and/or gcc then TCmini. For a full TC build use -tes or -tew. 
Examples 
${CY}emwrap.sh${NO}  prints help. 
${CY}emwrap.sh -uDwp${NO} Checks for updates in world and in the TC showing you them. 
${CY}emwrap.sh -uDwt${NO}==> checks emerge world -uD and only does TC update. 
${CY}emwrap.sh -uDwb${NO}==> updates the TC and then the world files. 
${CY}emwrap.sh -f{other flags}${NO} will fetch the files for you. 

New  emwrap.sh now can "emerge system -e" with or without the TC and remove all packages 
   built during the system emerge for the following "emerge world -e". This is a major 
   time savings as 130+ packages wont be rebuilt during the world half. 
${CY}emwrap.sh -db${NO} ,builds TC and sytem -e. When it completes run 
${CY}emwrap.sh -r${NO} ,this picks where -db stoped and builds the rest of the files in the 
   " world -e ". Why use this, well if you want to break an " emerge world -e " up into 2 
   chunks for two different nights this will do it. 
   When -p is used emwrap.sh will show what will be rebuilt. When -e is used 
   complete TC updates will be done. While learning how to use it do an ${CY}emwrap.sh -p 
   or -suDp${NO}, 
    
Options:    
   These first flags are the same as what you use with emerge [options] 
   -h, help    Display this help (default) 
   -f   Fetchs files only 
   -u   update 
   -D   deep    
   -e   Does an  emerge "--emptytree" world/sytem 
   -p   Just like pretend in emerge. Works with all other flags. 
   -N   Tells emerge to include installed packages where USE flags have changed since compilation. 
   -s, system   emerge system 
   -w, world    emerge world 
For use by the script 
   -t   Rebuilds the toolchain componets only 
   -b   Rebuilds the toolchain and emerges system/world packages. 
   -c, cont    Continues emwrap from where it stoped. To use rerun the same command 
         and add "c" and emwrap will start from where it stoped without haveing to rebuild 
         everything before. This is the same as --resume in emerge. 
   -d   This is a 2 part function. Does system -e build first  after emerge system you have 
          to run emwrap.sh -r to build the world files minus the system files from useing 
          the -d. 
   -r   Resumes building the wrld list, minus the system files.    
   nc   Turns off color in the script. You still get color in emerge out put.  
    
END 
} 

### Variables 
tc=""       #tc which TC items have updates useing case working 
eargs=""    #emerge default options 
bclass=""   # type of class, emerge "world" default 
prtnd=""    #emerge -p option 
ftch=""     # fetch files flag 
# testing for gcc and binutils config , also portage 
bin="0"; gcc="0"; por="0"; tc_conf="" 
# variable for the particular TC to be built. 
do_tc="";tc_list="" ;both=""; tst="" 
do_diff="" ; resum="" #for diff where wrld system files removed only does emtytree. 
cont=""     # varible for continueing a build from where it stoped. 
nc=""       # nc => no color 


function info(){ 
   clear 
   cat   <<END 
    
   $GR                         Runnig emwrap.sh 
   $GR Files made by emwrap.sh are located in /tmp/emwrap. Feel free 
   $GR to "rm -r /tmp/emwrap". If there were failures while building 
   $GR they are listed in failed.lst which is copied to ~/ , roots dir. $NO 
END 
} 

function dir_info(){ 
   # change file locations to /tmp/emwrap/{FILES} 
   # Changed to explicit directory invoke, because if used to build a system from scratch, 
   # ergo a new build, $HOME isnt set and every thing for root is writen to " / ". 
   if [ ! -d  /tmp/emwrap ];then 
      mkdir /tmp/emwrap;chmod 776 /tmp/emwrap;chown portage:portage /tmp/emwrap;cd /tmp/emwrap 
   else cd /tmp/emwrap 
   fi 

   if [ "$(pwd)" != "/tmp/emwrap" ] ;then 
      echo;echo $RD"Did not change to /tmp/emwrap. Bailing out!"$NO;echo 
      exit 1 
   fi 
} 

# For cleaning files sense they're emptied now by "continue" 
# adding if test for failed list 
function clean_up(){ 
   if [[  "${cont}" != "yes" || "$resum" != "yes" ]]; then    
      if [ -e failed.lst ]; then 
         cp /tmp/emwrap/failed.lst ~/failed.lst 
      fi 
      rm /tmp/emwrap/* 
   fi 
} 

function get_opts(){ 
   if [ $# -eq 0 ]; then 
      do_print_help="yes" 
   fi 

   while [[ $1 != "" ]]; do 
      if echo $1|grep -v - ; then 
         case $1 in 
            system   )   bclass="system" ;; 
            world   )   bclass="world" ;; 
            help   )   print_help ;; 
            nc      )   nc="yes" ;; 
         esac 
      fi 

      while getopts ":bcdDefgGhNoprstuwz " OPT; do 
         case $OPT in 
            h | \? )do_print_help="yes" ;; 
            D )    eargs="${eargs}${OPT}" ;; 
            e )    eargs="${eargs}${OPT}" ;; 
            s )    bclass="system" ;; 
            w )    bclass="world" ;; 
            N )    eargs="${eargs}${OPT}" ;; 
            u )    eargs="${eargs}${OPT}" ;; 
            g )    eargs="${eargs}${OPT}" ;; 
            G )    eargs="${eargs}${OPT}" ;; 
            p )    prtnd="p" ;; 
            f )    ftch="f" ;; 
            d )    do_diff="yes" ;; 
            r )    resum="yes" ;; 
            b )    both="yes" ;; 
            c )    cont="yes" ;; 
            t )    do_tc="yes" ;; 
            z )    tst="yes" ;; 
            * )    echo "\* OPT=$OPT";; 
         esac 
      done 
      shift 
   done 
} 

# TC filter 
function tc_filter(){ 
   awk '!/linux-h|glibc|binutils-|gcc-/' 
} 

function tc_check(){ 
   # testing for TC components. 
   if grep -Eq linux-h wrld.lst 
      then tc="${tc} 4";fi 
   if grep -Eq glibc wrld.lst 
      then tc="${tc} 3";fi 
   if grep -Eq binutils-[[0-9]]? wrld.lst 
      then tc="${tc} 2";fi 
   if grep -Eq gcc-[[:digit:]]? wrld.lst 
      then tc="${tc} 1";fi 
       
   # testing for gcc and binutils config , also portage 
   bin="0"; gcc="0"; por="0"; tc_conf="" 
   if grep -Eq binutils-[[:alpha:]]? wrld.lst 
      then bin=1 ; tc_conf="binutils-config $(echo $tc_conf)"; fi 
   if grep -Eq gcc-[[:alpha:]]? wrld.lst 
      then gcc=1 ; tc_conf="gcc-config $(echo $tc_conf)"; fi 
   if grep -Eq portage wrld.lst 
      then por=1 ; tc_conf="portage $(echo $tc_conf)"; fi 
   #shows what TC items have updates 
   if [[ $prtnd == "p" || $do_tc == "yes" ]] ; then 
      if [ $tc -ge 1 ] ;then 
         echo $RD"ToolChain updates found"$NO;echo 
      # For sorting "tc" to find the largest value 
         r="0"      # set "0" for greater than and to 10 for less than. 
         for n in $(echo ${tc});do    
            if [[ ${n} -gt ${r} ]]; then r=${n}; fi 
         done 

         case ${r} in 
            4 ) echo $BL"linux-headers update"$NO;; 
            3 ) echo $BL"glibc update"$NO;; 
            2 ) echo $BL"binutils update"$NO;; 
            1 ) echo $BL"gcc update"$NO;; 
         esac 

         echo 
         echo $BL"======================================================"$NO 
         echo 
      else 
         echo ${RD}"No toolchain update so proceed with a regular emwrap.sh -s/w" 
      fi 

      if [[ $por -eq 1 || $bin -eq 1 || $gcc -eq 1 ]];then 
         echo $RD"TC config componets have an update and will be built during the TC build"$NO          
         if [ $por -eq 1 ];then echo $BL"portage update"$NO;fi 
         if [ $bin -eq 1 ];then echo $BL"binutils-config update"$NO;fi 
         if [ $gcc -eq 1 ];then echo $BL"gcc-config update"$NO;fi 
         echo 
         echo $Bl"======================================================"$NO 
         echo 
      fi 
   fi 
} 

# function to print TC failed message and bail out 
function tc_faild(){ 
   echo ${RD}"${z} failed to build. Stoping script."${NO};exit 65 
} 

function wrld_lst(){ 
    # If for blocking regeneration of list if resume is used 
   if [[ "${cont}" != "yes" || "$resum" != "yes" ]];then 
      emerge $bclass -p$eargs|cut -f2 -d "]" -s|cut -f1 -d "[">wrld.lst 
   fi 
} 

# This is for the generation of the diff and resume lists. 
function diff_emrg(){ 
   # This "if "is for the generation of the list and if the the list need regeneration. 
   if [[ "${cont}" != "yes" ]];then 
      if [[  "${do_diff}" == "yes" || "${resum}" ==  "yes" ]]; then 
         emerge system -ep|cut -f2 -d "]" -s|cut -f1 -d "["|tc_filter>sys.lst 
         # Need sys.lst for resume to remove sys files 
         if [  "${do_diff}" == "yes" ] ; then cat sys.lst>build.lst ;fi 
      fi    
   # filters out sys files and puts the results into into the build list. 
      if  [ "${resum}" ==  "yes" ] ; then 
         emerge world -ep|cut -f2 -d "]" -s|cut -f1 -d "["|tc_filter>wrld.lst 
         for i in $(< sys.lst);do 
            grep -v $i wrld.lst>tmp;cat tmp>wrld.lst 
         done 
         cat wrld.lst>build.lst 
         if [ -e tmp ];then rm tmp ;fi 
      fi 
   fi 
   echo $GR"$(wc -l build.lst) packages in build.lst"$NO 
   sleep 1 
    
   count=1 ; s=$(cat build.lst|wc -l) 
   for z in $(< build.lst) ;do 
      echo  "${BL}${count} of ${s}" ; echo  ${GR}"$z"${NO}    
      emerge -${prtnd} --oneshot --nodeps =${z} || echo "${z}">> failed.lst 
      count=$(( count + 1 )) 
      grep -v "${z}" build.lst>tmp;cat tmp>build.lst 
   done 
   if [ -e tmp ];then rm tmp ;fi 
   if [ -s failed.lst ] ;then cat failed.lst ;fi 
} 

function list_emrg(){ 
   # blocks do_tc from running list_emerge with prntd 
   if [[ "$do_tc" == "yes" ]] ;then 
      : # : builtin for true 
      else    
      if [[ "$resum" != "yes" ]] ;then 
         cat wrld.lst|tc_filter >> wrld 
         count="" ; s=$(wc -l wrld) 
      else 
         count="" ; s=$(wc -l wrld) 
      fi 
      for z in $(< wrld) ;do 
         count=$(( count + 1 )) 
         echo  "${BL}${count} of ${s}" ; echo  ${GR}"$z"${NO} 
         # Dont need grep -v as portage handles it 
         emerge -${ftch} -${prtnd} --oneshot --nodeps =${z} || echo "${z}">> failed.lst 
         echo "$z and $(wc -l wrld)" 
         grep -v "${z}" wrld>tmp;cat tmp>wrld 
      done 
      if [ -e tmp ];then rm tmp ;fi 
   fi 
} 

function tc_emrg(){ 
   TC="linux-headers glibc $(echo $tc_conf) binutils gcc glibc binutils gcc" 
   TC_glb="glibc $(echo $tc_conf) binutils gcc glibc binutils gcc" 
   TCmini="$(echo $tc_conf) binutils gcc binutils gcc" 
   if [[ "${cont}" != "yes" ]];then    
      # For sorting "a" to find the largest value 
      r=0 
      for n in $(echo ${tc});do    
         if [[ ${n} -gt ${r} ]]; then r=${n};fi 
         done 
      case ${r} in 
         4 )  tc_list=$TC;; 
         3 )  tc_list=$TC_glb;; 
         2 )  tc_list=$TCmini;; 
         1 )  tc_list=$TCmini;; 
      esac 
   fi 
   echo $RD"${tc_list}"$NO 
   count=0 ; s=$( (echo ${tc_list})|wc -w) 
   for z in ${tc_list};do 
      count=$(( count + 1 )) 
      echo  "${BL}${count} of ${s}" ; echo  ${GR}"$z"${NO} 
      emerge -${ftch} -${prtnd} =${z} || tc_faild 
      grep -v "${z}" build.lst>tmp;cat tmp>build.lst 
   done 
   if [ -e tmp ]; then rm tmp ;fi 
   echo ${RD}"End of ToolChain update"${NO};echo 
} 


################# End functions 
#################   Main   ################ 

get_opts $@ 
colors 
info 
dir_info 
wrld_lst 

   if [ "$do_print_help" == "yes" ]; then 
      print_help 
      exit 0 
   fi 

# Builds the TC 
# the first if" shows TC if you use the pretend switch. The lower one that is 
# commented out only shows the TC stuff if the "t" or "b" switch is used 
#if [[ "$do_tc" == "yes" || "$both" == "yes" || "$prtnd" == "p" ]]; then 
   if [[ "$do_tc" == "yes" || "$both" == "yes" ]]; then 
      tc_check ; tc_emrg 
   fi 
# does diff of world and system 
   if [[ "$do_diff" == "yes" || "$resum" == "yes"  ]]; then 
      diff_emrg 
   fi 
# the build function for system and world. Added "bclass" so that it would actually do 
# an update. ;^) 
   if [[ "$both" == "yes" || "$prtnd" == "p" || "$ftch" == "yes" || "$bclass" != "" || "$resum" = "yes" ]]; then 
      wrld_lst;list_emrg;if [ -s failed.lst ] ;then cat failed.lst ;fi 
   fi 
    
clean_up 
exit 0 

#vim:ts=4:sw=4
