# ~/.bashrc: executed by bash(1) for non-login shells.

export PS1='\h:\w\$ '
umask 022

# You may uncomment the following lines if you want `ls' to be colorized:
export LS_OPTIONS='--color=auto'
eval "`dircolors`"
alias ls='ls $LS_OPTIONS'
alias ll='ls $LS_OPTIONS -l'

alias lsl='ls $LS_OPTIONS -lA'
alias lsr='ls $LS_OPTIONS -lAR'

alias lr=lsr
alias l=lsl
#
# Some more alias to avoid making mistakes:
alias rm='rm -i -v'
alias cp='cp -i -prv'
alias mv='mv -i -v'


# kidd -- misc stuff

#files
alias chmod='chmod --preserve-root'


#networking
alias openports='echo "COMMAND     PID       USER   FD      TYPE     DEVICE     SIZE       NODE NAME"; lsof|sort|grep LISTEN'
alias portgrep='echo "COMMAND     PID       USER   FD      TYPE     DEVICE     SIZE       NODE NAME"; lsof|sort|grep LISTEN|grep -i'

#editors
alias e='e3ne'

#screen
alias cls='reset;clear'

# some from http://www.pixelbeat.org/cmdline.html

alias realpath='readlink -f'
alias rpwd=realpath
#
alias clc='echo $@|bc -l'

#processes, sysinfo
alias psgrep='echo "USER       PID %CPU %MEM   VSZ  RSS TTY      STAT START   TIME COMMAND"; ps axuw|grep -v "%CPU %MEM"|grep -v "grep "|grep -i'
alias psg=psgrep
alias psu='ps uw -u'

alias pscpu="ps -e -o pcpu,cpu,nice,state,cputime,args --sort pcpu | sed '/^ 0.0 /d'"
alias psmem="ps -e -o rss=,args= | sort -b -k1,1n | pr -TW\$COLUMNS|tail"
alias cpuload="ps -eao \"pcpu\" | awk '{a+=\$1} END {print a}'"
alias memload="ps -eao \"pmem\" | awk '{a+=\$1} END {print a}'"
alias pscputop='echo "USER       PID %CPU %MEM   VSZ  RSS TTY      STAT START   TIME COMMAND"; ps axuw|sort -r -k3|grep -v "%CPU %MEM"|head'
alias psmemtop='echo "USER       PID %CPU %MEM   VSZ  RSS TTY      STAT START   TIME COMMAND"; ps axuw|sort -r -k4|grep -v "%CPU %MEM"|head'

#alias prochist='ps axuw|sort -k9 -r'

alias crashtest='crashme +16384 123 100 0:05:00 5'

alias stl='export TERM=linux'
alias stx='export TERM=xterm'
alias sta='export TERM=ansi'
alias stv='export TERM=vt100'

alias emc='mc -e'
alias mce=emc

alias lsc='ls --color'
alias lsl='ls -lA'
#alias lsr

/usr/games/fortune -s
