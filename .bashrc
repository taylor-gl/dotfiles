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

cdls() { cd "$@" && ls; }

# Add emacs as editor
# -c creates a new frame (window)
# -a="" ensures the daemon will be opened if necessary
export EDITOR='emacs'
e() { (emacs "$@" &> /dev/null &) }

alias youtube-to-mp3='youtube-dl --extract-audio --audio-format mp3'

# use vim as a pager instead of less
alias less=vimpager
# alias less='/usr/share/vim/vim74/macros/less.sh'

# limit mv and rm to prevent unintentional sadness
alias mv=' timeout 8 mv -iv'
alias rm=' timeout 3 rm -Iv --one-file-system'

alias ..='cd ..'
alias ...='cd ../..'

# add ~/.scripts to path
PATH=$PATH:~/.scripts:.

# add blog scripts to path
PATH=$PATH:~/blog/scripts/

# add ~/.local/bin to path
PATH=$PATH:~/.local/bin
export PATH=/usr/local/bin:${PATH}

# add sbin folders to path
export PATH=$PATH:/sbin
export PATH=$PATH:/usr/sbin

# add emacs bin to path
export PATH=$PATH:~/.emacs.d/bin

# Add ruby gem bin to path
export PATH=$PATH:/home/taylor/.gem/ruby/2.5.0/bin

# Add rust cargo to path
export PATH=$PATH:/home/taylor/.cargo/bin
export PATH=$PATH:/home/taylor/.cargo/env

# set the path for locate to the home directory
export LOCATE_PATH=/home/taylor/.locate.db

# Add go to path
export GOROOT=/usr/local/go
export PATH=$PATH:$GOROOT/bin

# add pyenv to path
export PATH="/home/taylor/.pyenv/bin:$PATH"
eval "$(pyenv init -)"
eval "$(pyenv virtualenv-init -)"

# Load nvm into path:
export NVM_DIR="$([ -z "${XDG_CONFIG_HOME-}" ] && printf %s "${HOME}/.nvm" || printf %s "${XDG_CONFIG_HOME}/nvm")"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"

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

export CALIBRE_USE_SYSTEM_THEME=1

# use gtk for qt applications
QT_QPA_PLATFORMTHEME=gtk2

# set color variables (base0 called base0_ for consistency with i3 config file, which is named as such to prevent errors)
export base03="#002b36"
export base02="#073642"
export base01="#586e75"
export base00="#657b83"
export base0_="#839496"
export base1="#93a1a1"
export base2="#eee8d5"
export base3="#fdf6e3"
export yellow="#b58900"
export orange="#cb4b16"
export red="#dc322f"
export magenta="#d33682"
export violet="#6c71c4"
export blue="#268bd2"
export cyan="#2aa198"
export green="#859900"

source ~/.bash_completion/alacritty

# export DPI setting for alacritty
export WINIT_HIDPI_FACTOR=1.0 alacritty
