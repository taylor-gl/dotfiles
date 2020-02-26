#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

# make utilities such as grep and ls use colored output
alias ls='ls -F --color=auto'
# PS1='[\u@\h \W]\$ '
eval $(dircolors -b)
alias grep='grep --color=auto'
alias diff=colordiff

# customize bash prompts
export PS1="[\w]\\$ "

# use vim as a pager instead of less
alias less=vimpager
# alias less='/usr/share/vim/vim74/macros/less.sh'

# add an alias to colorize cat using vim
alias cat="vimcat"

# limit mv and rm to prevent unintentional sadness
alias mv=' timeout 8 mv -iv'
alias rm=' timeout 3 rm -Iv --one-file-system'

# add ~/.scripts to path
PATH=$PATH:~/.scripts:.

# add ~/.local/bin to path
PATH=$PATH:~/.local/bin
export PATH=/usr/local/bin:${PATH}

# Add ruby gem bin to path
export PATH=$PATH:/home/taylor/.gem/ruby/2.5.0/bin

# Add rust cargo to path
export PATH=$PATH:/home/taylor/.cargo/bin

# add pyenv to path
export PATH="/home/taylor/.pyenv/bin:$PATH"
eval "$(pyenv init -)"
eval "$(pyenv virtualenv-init -)"

# enable powerline for bash
powerline-daemon -q
POWERLINE_BASH_CONTINUATION=1
POWERLINE_BASH_SELECT=1
if [ -f /usr/local/lib/python2.7/dist-packages/powerline/bindings/bash/powerline.sh ]; then
    source /usr/local/lib/python2.7/dist-packages/powerline/bindings/bash/powerline.sh
fi
man() {
    LESS_TERMCAP_md=$'\e[01;31m' \
    LESS_TERMCAP_me=$'\e[0m' \
    LESS_TERMCAP_se=$'\e[0m' \
    LESS_TERMCAP_so=$'\e[01;44;33m' \
    LESS_TERMCAP_ue=$'\e[0m' \
    LESS_TERMCAP_us=$'\e[01;32m' \
    command man "$@"
}

# Add emacs as editor
# -c creates a new frame (window)
# -a="" ensures the daemon will be opened if necessary
export EDITOR='emacsclient -c -a=""'
alias e='emacsclient -c -a=""'

alias youtube-to-mp3='youtube-dl --extract-audio --audio-format mp3'

export CALIBRE_USE_SYSTEM_THEME=1

cdls() { cd "$@" && ls; }

# >>> conda initialize >>>
# !! Contents within this block are managed by 'conda init' !!
__conda_setup="$('/home/taylor/.anaconda3/bin/conda' 'shell.bash' 'hook' 2> /dev/null)"
if [ $? -eq 0 ]; then
    eval "$__conda_setup"
else
    if [ -f "/home/taylor/.anaconda3/etc/profile.d/conda.sh" ]; then
        . "/home/taylor/.anaconda3/etc/profile.d/conda.sh"
    else
        export PATH="/home/taylor/.anaconda3/bin:$PATH"
    fi
fi
unset __conda_setup
# <<< conda initialize <<<

# export DPI setting for alacritty
export WINIT_HIDPI_FACTOR=1.0 alacritty

# Load nvm into path:
export NVM_DIR="$([ -z "${XDG_CONFIG_HOME-}" ] && printf %s "${HOME}/.nvm" || printf %s "${XDG_CONFIG_HOME}/nvm")"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
