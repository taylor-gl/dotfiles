#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

# make utilities such as grep and ls use colored output
alias ls='ls --color=auto'
PS1='[\u@\h \W]\$ '
eval $(dircolors -b)
alias grep='grep --color=auto'
alias diff=colordiff

# customize bash prompts
export PS1="[\w]\\$ "

# use vim as a pager instead of less
# alias less='/usr/share/vim/vim74/macros/less.sh'

# limit mv and rm to prevent unintentional sadness
alias mv=' timeout 8 mv -iv'
alias rm=' timeout 3 rm -Iv --one-file-system'

# add ~/.scripts to path
PATH=$PATH:~/.scripts:.

export QSYS_ROOTDIR="/home/taylor/software/Quartus/quartus/sopc_builder/bin"

export ALTERAOCLSDKROOT="/home/taylor/software/Quartus/hld"

# add an alias to run quartus properly
alias quartus="quartus --64bit"

# add an alias to colorize cat using vim
alias cat="vimcat"

# enable powerline for bash
if [ -f /usr/lib/python3.6/site-packages/powerline/bindings/bash/powerline.sh ]; then
    source /usr/lib/python3.6/site-packages/powerline/bindings/bash/powerline.sh
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

export PATH=/opt/cocos2d-x/tools/cocos2d-console/bin:/opt/cocos2d-x/tools/cocos2d-console/plugins/plugin_package:${PATH}

export PATH=/usr/local/bin:${PATH}

# Add environment variable COCOS_CONSOLE_ROOT for cocos2d-x
export COCOS_CONSOLE_ROOT=/opt/cocos2d-x/tools/cocos2d-console/bin
export PATH=$COCOS_CONSOLE_ROOT:$PATH

# Add environment variable COCOS_X_ROOT for cocos2d-x
export COCOS_X_ROOT=/opt
export PATH=$COCOS_X_ROOT:$PATH

# Add environment variable COCOS_TEMPLATES_ROOT for cocos2d-x
export COCOS_TEMPLATES_ROOT=/opt/cocos2d-x/templates
export PATH=$COCOS_TEMPLATES_ROOT:$PATH
