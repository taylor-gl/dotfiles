# A collection of my dotfiles

I'm currently running Debian on my desktop with i3 and emacs. Everything that can be Solarized dark is Solarized dark.

-----

## main dotfiles
| File         | Description                                                                                                                                          |
|--------------|------------------------------------------------------------------------------------------------------------------------------------------------------|
| .Xkeymap     | Defines a few custom changes to the X keymap. Mostly make F15 a modifier key so I can use it as Hyper_R (I have it bound on my Ergodox EZ keyboard). |
| .bashrc      | Simple bash config which mostly just sets up a few aliases and adds a few things to the path.                                                        |
| .profile     | Calls .bashrc.                                                                                                                                       |
| configure.sh | A work-in-progress, but eventually I want this script to completely and idempotently configure a fresh Debian install for me.                        |
| make.sh      | Makes symlinks to all of the dotfiles in this repo.                                                                                                  |

-----

## doom emacs stuff
| File        | Description                                                                                                                                                                                                                                                                   |
|-------------|-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| init.el     | The default doom packages I have enabled. Some stuff I have enabled, but don't use yet, like the RSS stuff.                                                                                                                                                                   |
| packages.el | Packages which don't come with Doom. They include [emojify](https://github.com/iqbalansari/emacs-emojify) to add emoji support 😂, and [evil-colemak-basics](https://github.com/wbolster/evil-colemak-basics) to provide basic colemak keybindings (though many are missing). |
| config.el            | My personal emacs config. It includes a lot of remapping to colemak keybindings, as well as [Fira Code](https://github.com/tonsky/FiraCode/wiki/Emacs-instructions).                                                                                                                                                                                                                                                                              |

-----

## scripts
| File                                          | Description                                                                                                                                   |
|-----------------------------------------------|-----------------------------------------------------------------------------------------------------------------------------------------------|
| beep.sh and toggle_beep.sh                    | Plays a sound every 15 minutes, if toggled.                                                                                                   |
| channel_id_to_rss.sh                          | Converts a YouTube channel id to its corresponding RSS feed URL.                                                                              |
| dolphin_style.qss                             | Style for the Dolphin file browser.                                                                                                           |
| empty                                         | Empties the Dolphin file browser trash.                                                                                                       |
| set-brightness-0.sh and set-brightness-100.sh | Set my monitor's brightness using DDC/CI. I run these daily with a cron job to dim my monitor at night. Better than just a blue light filter. |
| toggle_loopback.sh                            | Toggles loopback on my mic so I can hear myself through my mic.                                                                               |

-----

## i3 stuff
In i3 I use i3bar with i3blocks. Blocks come from various repositories, and there are some custom blocks as well.
| File            | Description                                       |
|-----------------|---------------------------------------------------|
| config          | The main i3 config                                |
| i3blocks.conf   | The i3blocks config                               |
| i3lock-pixel.sh | A pixellated i3 lock which I don't currently use. |

### Blocks I use
Some blocks either come from [i3blocks](https://github.com/vivien/i3blocks) itself, [i3blocks-contrib](https://github.com/vivien/i3blocks-contrib), or [Anachron/i3blocks](https://github.com/Anachron/i3blocks). Blocks of note:
| Block                 | Description                                                                                                                                   |
|-----------------------|-----------------------------------------------------------------------------------------------------------------------------------------------|
| vlc-filename-duration | A block for displaying information about, and controlling, currently playing vlc files, based on the mediaplayer block from i3blocks-contrib. |
| mail                  | A block showing the number of emails in my gmail inbox.                                                                                       |
| weather               | A weather block from [here](http://kumarcode.com/Colorful-i3/).                                                                               |
| curl ipinfo.io/ip     | A good way to get my external ip in my i3bar.                                                                                                 |
| nordvpn.sh            | A button to connect/disconnect me to Nord VPN.                                                                                                |
