# ~/.profile: executed by the command interpreter for login shells.
# This file is not read by bash(1), if ~/.bash_profile or ~/.bash_login
# exists.
# see /usr/share/doc/bash/examples/startup-files for examples.
# the files are located in the bash-doc package.

# the default umask is set in /etc/profile; for setting the umask
# for ssh logins, install and configure the libpam-umask package.
#umask 022

# if running bash
if [ -n "$BASH_VERSION" ]; then
    # include .bashrc if it exists
    if [ -f "$HOME/.bashrc" ]; then
	. "$HOME/.bashrc"
    fi
fi

# set PATH so it includes user's private bin if it exists
if [ -d "$HOME/bin" ] ; then
    PATH="$HOME/bin:$PATH"
fi

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


# export DPI setting for alacritty
export WINIT_HIDPI_FACTOR=1.0 alacritty


export PATH="$HOME/.cargo/bin:$PATH"
