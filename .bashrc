#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

# enable bash completion in interactive shells
if ! shopt -oq posix; then
    # system completions for bash
    if [ -f /usr/share/bash-completion/completions ]; then
        . /usr/share/bash-completion/
    elif [ -f /usr/share/bash-completion/bash_completion ]; then
        . /usr/share/bash-completion/bash_completion
    elif [ -f /etc/bash_completion ]; then
        . /etc/bash_completion
    fi
    # user completions for bash
    if [ -f ~/.bash_completion ]; then
        . ~/.bash_completion
    fi
fi

# if the command-not-found package is installed, use it
if [ -x /usr/lib/command-not-found -o -x /usr/share/command-not-found/command-not-found ]; then
    function command_not_found_handle {
        # check because c-n-f could've been removed in the meantime
        if [ -x /usr/lib/command-not-found ]; then
            /usr/lib/command-not-found -- "$1"
            return $?
        elif [ -x /usr/share/command-not-found/command-not-found ]; then
            /usr/share/command-not-found/command-not-found -- "$1"
            return $?
        else
            printf "%s: command not found\n" "$1" >&2
            return 127
        fi
    }
fi

# Do not overwrite files when redirecting output by default.
set -o noclobber

# Wrap the following commands for interactive use to avoid accidental file overwrites.
rm() { command rm -i "${@}"; }
cp() { command cp -i "${@}"; }
mv() { command mv -i "${@}"; }

# limit mv and rm to prevent unintentional sadness
# alias mv=' timeout 8 mv -iv'
# alias rm=' timeout 3 rm -Iv --one-file-system'

# Aliases for faster movement up directories
alias ..="cd .."
alias ...="cd ../.."
alias ....="cd ../../.."
alias .....="cd ../../../.."
alias ......="cd ../../../../.."
alias .......="cd ../../../../../.."
alias ........="cd ../../../../../../.."
alias .........="cd ../../../../../../../.."

# make utilities such as grep and ls use colored output
eval $(dircolors -b)
alias grep='grep --color=auto'
alias diff=colordiff
# colored ls with icons
alias ls='lsd --color=auto'
# alias ls='ls -F --color=auto'

# Add emacs as editor
# --alternate-editor="" ensures the daemon will be opened if necessary
# --eval "(taylor-gl/emacsclient)" runs some functions I want run when I run emacsclient; However, I don't add this to EDITOR because it breaks e.g. git launching my EDITOR
export EDITOR='emacsclient --create-frame --alternate-editor=""'
e() { (emacsclient --create-frame --no-wait --alternate-editor="" --eval "(taylor-gl/emacsclient)" "$@" &> /dev/null &) }

# Show git branch name (from https://askubuntu.com/a/946716)
force_color_prompt=yes
color_prompt=yes
parse_git_branch() {
 git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/(\1)/'
}
if [ "$color_prompt" = yes ]; then
 PS1='${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u\[\033[00m\]:\[\033[01;34m\]\w\[\033[01;31m\]$(parse_git_branch)\[\033[00m\]\$ '
else
 PS1='${debian_chroot:+($debian_chroot)}\u:\w$(parse_git_branch)\$ '
fi
unset color_prompt force_color_prompt

alias ..='cd ..'
alias ...='cd ../..'
cdls() { cd "$@" && ls; }

alias trash=trash-put

alias youtube-to-mp3='youtube-dl --extract-audio --audio-format mp3'

# PATH
PATH=$PATH:~/.scripts:.
PATH=$PATH:~/.build/
PATH=$PATH:~/blog/scripts/
PATH=$PATH:~/.local/kitty.app/bin
PATH=$PATH:~/.local/bin
PATH=$PATH:/usr/local/bin
PATH=$PATH:/sbin
PATH=$PATH:/usr/sbin
PATH=$PATH:~/.emacs.d/bin
PATH=$PATH:~/.local/share/flatpak/exports/bin
PATH=$PATH:/var/lib/flatpak/exports/bin
PATH=$PATH:~/.build/elixir-1.13.3/bin
PATH=$PATH:~/.build/otp_src_24.0.2/bin
PATH=$PATH:~/.nvm/versions/node/v16.14.0/bin

# set the path for locate to the home directory
export LOCATE_PATH=/home/taylor/.locate.db

# Languages
PATH=$PATH:/home/taylor/.gem/ruby/2.5.0/bin
PATH=$PATH:/home/taylor/.cargo/bin
PATH=$PATH:/home/taylor/.cargo/env
PATH=$PATH:/usr/local/go/bin
export ERL_LIBS="/home/taylor/.asdf/installs/elixir/1.11.2/lib/elixir/lib"
export NVM_DIR="$([ -z "${XDG_CONFIG_HOME-}" ] && printf %s "${HOME}/.nvm" || printf %s "${XDG_CONFIG_HOME}/nvm")"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"

# export DPI setting for alacritty
export WINIT_HIDPI_FACTOR=1.0 alacritty

# Change keyboard repeat rate
xset r rate 200 100

# Set hyper key
xmodmap ~/.Xmodmap

# Add zoxide (faster cd)
eval "$(zoxide init bash)"

# Add fuck
eval $(thefuck --alias)

# export gpg key
export GPG_TTY=$(tty)
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

# Generated for envman. Do not edit.
[ -s "$HOME/.config/envman/load.sh" ] && source "$HOME/.config/envman/load.sh"

