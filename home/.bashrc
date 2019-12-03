case $- in
  *i*) ;;
  *) return;;
esac

###########################
#  Environment Variables  #
###########################
export CLICOLOR=1
export GEM_HOME="$(ruby -e 'print Gem.user_dir')"
export GPG_TTY="$(tty)"

PATH="$HOME/.local/bin:/usr/local/opt/python/libexec/bin:/usr/local/sbin:$PATH"
PATH+=":$HOME/.cargo/bin"
PATH+=":$GEM_HOME/bin"
PATH+=":$(python3 -c 'import site; print(site.getuserbase())')/bin"
PATH+=":$GOPATH/bin"
export PATH

if [[ -f ~/.nix-profile/etc/profile.d/nix.sh ]]; then
  source ~/.nix-profile/etc/profile.d/nix.sh
fi

###########################
#  Aliases and Functions  #
###########################
alias grep='grep --color=auto'
alias fgrep='fgrep --color=auto'
alias egrep='egrep --color=auto'
alias ls='ls -F'
alias ll='ls -lh'
alias la='ls -lAh'
alias qlook='qlmanage -p'
alias sudoedit='sudo -e'
command -v hub > /dev/null 2>&1 && alias git='hub'

#############
#  History  #
#############
HISTCONTROL=ignoreboth
HISTSIZE=1000
HISTFILESIZE=2000
shopt -s cmdhist
shopt -s lithist
shopt -s histappend

##########
#  Misc  #
##########
shopt -s checkjobs 2>/dev/null
shopt -s checkwinsize
shopt -s globstar 2>/dev/null
stty -ixoff -ixon # disable flow control

if [ -f /usr/local/etc/bash_completion ]; then
  . /usr/local/etc/bash_completion
fi

source ~/.local/opt/fzftools/fzftools.bash

###########
#  Theme  #
###########
if [[ $TERM == "dumb" ]]; then
  PS1='\u@\h:\w\$ '
  return
fi

unset LS_COLORS # clear distro defaults

__prompt_color='\[\e[1m\]'
__prompt_login='\u'
__prompt_title=''
if [[ -n "$SSH_CONNECTION" ]]; then
  __prompt_color='\[\e[1;32m\]'
  __prompt_login+='@\h'
  __prompt_title='\[\e]0;\u@\h:\w\a\]'
fi
if (( EUID == 0 )); then
  __prompt_color='\[\e[1;31m\]'
fi
PS1=$__prompt_title$__prompt_color$__prompt_login
PS1+='\[\e[0;1m\]:\[\e[34m\]\w\[\e[0;1m\]\$\[\e[0m\] '
unset __prompt_color __prompt_login __prompt_title
