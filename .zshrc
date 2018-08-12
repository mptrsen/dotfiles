HISTFILE=~/.zsh_history
HISTSIZE=1000000
SAVEHIST=1000000
setopt hist_ignore_dups
setopt hist_verify
setopt hist_ignore_dups
# don't share history across sessions, it is confusing
unsetopt share_history
setopt append_history
setopt hist_ignore_space
setopt appendhistory noautoremoveslash
setopt prompt_subst
unsetopt autocd beep nomatch notify 

# emacs mode
bindkey -e
# reduce esc lag to 0.1 s
KEYTIMEOUT=1
# some keybindings that aren't in vi mode
bindkey '^P' up-history
bindkey '^N' down-history
bindkey '^w' backward-kill-word
bindkey '^R' history-incremental-search-backward
#bindkey '^N' history-incremental-search-forward
bindkey '^A' beginning-of-line
bindkey '^E' end-of-line
bindkey '^[.' insert-last-word

# End of lines configured by zsh-newuser-install
# The following lines were added by compinstall
zstyle :compinstall filename '/home/mpetersen/.zshrc'

# Word separators
setopt magic_equal_subst	# enable completion after equal signs
WORDCHARS=

# Automatically continue jobs that are disowned
setopt autocontinue

# load completion module
autoload -Uz compinit
compinit

#allow tab completion in the middle of a word
setopt COMPLETE_IN_WORD

# End of lines added by compinstall
setopt longlistjobs

# the prompt
PROMPT="[20%D %T] %B%F{blue}%M%f%b"
if [[ ! -z $SSH_TTY ]]; then
	PROMPT="${PROMPT} at %m"
fi
# make the $ red if the previous command failed (exit status non-zero), yellow otherwise
# %(X,iftrue,iffalse) is the ternary operator syntax that checks X
PROMPT="${PROMPT}:%B%~ %(?,%F{yellow},%F{red})$%f%b "

# git status info in right prompt
autoload -Uz vcs_info
zstyle ':vcs_info:*' enable git
zstyle ':vcs_info:*' formats "[%b]"
precmd () { vcs_info }
RPS1='${vcs_info_msg_0_}'

# i have no idea what this does
case $TERM in
    *xterm*)
        precmd () {print -Pn "\e]0;%n@%M: %~\a"}
        ;;
esac

# trap Ctrl+C and print ^C
TRAPINT() {
	print -n -u2 '^C'
	return $((128+$1))
} 

solve() {
	echo "scale=4; $@" | bc -l
}

# some aliases
alias grep='grep --color=auto'
alias ls="ls --color"
alias ll="ls -l"
alias la='ls -a'
alias lla='ls -la'
alias lh="ls -lh"
alias lt="ls -lt"
alias less='less -i'
alias l='less'
alias sv="seaview -fontsize 8"
alias lc='wc -l'
alias seaview='seaview -fontsize 12'
alias dstat='dstat --load -cdnms --top-mem --top-cpu'
alias apsw='python -c "import apsw; apsw.main()"'
alias sqlite3='apsw'
alias h="head"
alias t="tail"
alias ct="column -s '	' -tn"
alias L="less -S"
alias g="grep"
alias e="evince"
alias lo="libreoffice"
alias liw="libreoffice --writer"
alias lic="libreoffice --calc"
alias lii="libreoffice --impress"
alias tmux="TERM=xterm-256color tmux"
alias add='awk -f ~/scripts/add.awk'

# environment variables
export WISECONFIGDIR=/home/mpetersen/hamstrad/wisecfg
export PERL_LOCAL_LIB_ROOT="/home/mpetersen/perl5:$PERL_LOCAL_LIB_ROOT"
export PERL_MB_OPT="--install_base "/home/mpetersen/perl5""
export PERL_MM_OPT="INSTALL_BASE=/home/mpetersen/perl5"
PERL5LIB="/home/mpetersen/local/share/perl5"
PERL5LIB="/home/mpetersen/local/lib/perl5:$PERL5LIB"
PERL5LIB="/home/mpetersen/perl5/lib/perl5:$PERL5LIB"
export PERL5LIB
# Add some dirs to PATH
## Locally installed programs
PATH="/home/mpetersen/local/bin:$PATH"
## TeXLive 2017
PATH="/home/mpetersen/local/texlive/2018/bin/x86_64-linux:$PATH"
## Perl libraries
PATH="/home/mpetersen/perl5/bin:/home/mpetersen/local/share/miniconda3/bin:$PATH"
export PATH
export EDITOR="/usr/bin/vim"
export TIME_STYLE="long-iso"
eval `dircolors ~/.dir_colors`

# enable environment modules
source /usr/share/modules/init/zsh
