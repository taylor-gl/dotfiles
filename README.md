# A collection of my dotfiles

I'm currently running Linux Mint on my desktop with cinnamon and emacs. I use a custom pastel theme for everything.

-----

## main dotfiles
| File                                        | Description                                                                                                   |
|---------------------------------------------|---------------------------------------------------------------------------------------------------------------|
| .kitty.conf                                 | Configuration for the [kitty terminal emulator](https://github.com/kovidgoyal/kitty), including pastel theme. |
| .bashrc                                     | Simple bash config which mostly just sets up a few aliases and adds a few things to the path.                 |
| .gitconfig                                  | Git config, including directory-specific GPG signing information.                                             |
| .xinitrc                                    | Launches Xorg and i3 when I run `startx`                                                                      |
| ssh.zip and gnupg.zip                       | Password protected `.ssh` and `.gnupg` folders.                                                               |
| exported_dropbox_accounts.csv.gpg_symmetric | Password protected password manager backup                                                                    |
| .xprofile                                   | Settings like cursor size, and binding the hyper key on my keyboard                                           |


-----

## emacs stuff
| File      | Description                                                                                             |
|-----------|---------------------------------------------------------------------------------------------------------|
| init.el   | My emacs config file. I was using doom emacs, but I switched to vanilla. I still use the doom modeline. |


-----

## my custom scripts
| File                                                   | Description                                                                                                                                   |
|--------------------------------------------------------|-----------------------------------------------------------------------------------------------------------------------------------------------|
| .scripts/channel_id_to_rss.sh                          | Converts a YouTube channel id to its corresponding RSS feed URL.                                                                              |
| .scripts/set-brightness-0.sh and set-brightness-100.sh | Set my monitor's brightness using DDC/CI. I run these daily with a cron job to dim my monitor at night. Better than just a blue light filter. |


-----

## vivaldi css
| File                | Description                                                                                                                                               |
|---------------------|-----------------------------------------------------------------------------------------------------------------------------------------------------------|
| vivaldi_css         | CSS for the vivaldi web browser, which vivaldi has a [setting to load from](https://forum.vivaldi.net/topic/37802/css-modifications-experimental-feature) |
| vimium-options.json | Colemak settings for the vimium browser extension. It gives vim-like keybindings for navigation in the browser.                                           |
