# Lines configured by zsh-newuser-install
HISTFILE=~/.zsh_history
HISTSIZE=1000000
SAVEHIST=1000000
setopt appendhistory sharehistory noautoremoveslash magic_equal_subst histignoredups
unsetopt autocd beep nomatch notify 
bindkey -e
# End of lines configured by zsh-newuser-install
# The following lines were added by compinstall
zstyle :compinstall filename '/home/malty/.zshrc'

autoload -U compinit promptinit
compinit
promptinit; prompt gentoo

# Word separators
WORDCHARS=

# Automatically continue jobs that are disowned
setopt autocontinue

autoload -Uz compinit
compinit
# End of lines added by compinstall
setopt longlistjobs
PROMPT='%B%F{blue}%n%f at %F{blue}%M%f:%~ %F{yellow}$%f%b '
PATH="/home/malty/perl5/bin:/home/malty/local/bin:$PATH"

alias ls="ls --color"

case $TERM in
    *xterm*)
        precmd () {print -Pn "\e]0;%n@%M: %~\a"}
        ;;
esac
alias smbfind=findsmb
alias ge=geeqie
export WISECONFIGDIR=/home/malty/thesis/hamstrsearch_local_v8_mpmod/wisecfg/
export PERL5LIB=/home/malty/local/share/perl5
export EDITOR=/usr/bin/vim
alias f=find
alias ll='ls -l'
alias la='ls -a'
alias lh='ls -lh'
alias zmbcluster='echo "ssh mpetersen@131.220.228.166";ssh mpetersen@131.220.228.166'
alias l=less
alias v=vim
alias l=less
alias history='history -n 1000'
alias h=head
alias t=tail
alias lc='wc -l'
alias grep='grep --color'
alias date='date "+%a %Y-%m-%d %H:%M:%S %Z"'
