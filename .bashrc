# /etc/skel/.bashrc:
#
# This file is sourced by all *interactive* bash shells on startup,
# including some apparently interactive shells such as scp and rcp
# that can't tolerate any output.  So make sure this doesn't display
# anything or bad things will happen !


# Test for an interactive shell.  There is no need to set anything
# past this point for scp and rcp, and it's important to refrain from
# outputting anything in those cases.
if [[ $- != *i* ]] ; then
	# Shell is non-interactive.  Be done now!
	return
fi

# Enable colors for ls, etc.  Prefer ~/.dir_colors #64489
#if [[ -f ~/.dir_colors ]]; then
#	eval `dircolors -b ~/.dir_colors`
#else
#	eval `dircolors -b /etc/DIR_COLORS`
#fi
alias ls="ls --color=auto"
alias ll="ls --color=auto -lh"
#unalias rm

# Change the window title of X terminals 
case $TERM in
	xterm*|rxvt*|Eterm)
		PROMPT_COMMAND='echo -ne "\033]0;${USER}@${HOSTNAME%%.*}:${PWD/$HOME/~}\007"'
		;;
	screen)
		PROMPT_COMMAND='echo -ne "\033_${USER}@${HOSTNAME%%.*}:${PWD/$HOME/~}\033\\"'
		;;
esac

export CVSROOT=/home/malty/Repository
PS1='\[\033[01;34m\]\h\[\033[01;39m\] \w \[\033[01;33m\]\$\[\033[00m\] '

export PERL_MB_OPT="--install_base /home/malty/perl5"
export PERL_MM_OPT="INSTALL_BASE=/home/malty/perl5"
export PERL5LIB="/home/malty/perl5/lib/perl5/i486-linux-gnu-thread-multi:/home/malty/perl5/lib/perl5:$PERL5LIB"
#export PATH="$PATH"
export WISECONFIGDIR=~/thesis/packages/wise2.2.0/wisecfg
