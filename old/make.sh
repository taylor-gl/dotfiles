#!/bin/bash

dir=~/Dropbox/dotfiles
olddir=~/.dotfiles_backup
files=".bashrc .i3 doom.d .scripts .profile .Xkeymap"

echo "Creating $olddir in ~ as a backup of existing dotfiles in ~"
mkdir -p $olddir
echo "... done."

echo "Changing to the $dir directory."
cd $dir
echo "... done."

for file in $files; do
    echo "Moving existing dotfiles from ~ to $olddir"
    mv ~/$file $olddir
    echo "Creating symlink to $file in home directory"
    ln -s $dir/$file ~/$file
done

echo "Setup complete."
