# A collection of my dotfiles

I'm currently running Gentoo on my desktop with i3 and emacs. Everything that can be ~~Solarized dark~~ [Gruvbox](https://github.com/morhetz/gruvbox) is ~~Solarized dark~~ Gruvbox.

-----

## main dotfiles
| File                  | Description                                                                                                           |
|-----------------------|-----------------------------------------------------------------------------------------------------------------------|
| .alacritty.yml        | Configuration for the [alacritty terminal emulator](https://github.com/alacritty/alacritty), including gruvbox theme. |
| .bashrc               | Simple bash config which mostly just sets up a few aliases and adds a few things to the path.                         |
| .gitconfig            | Git config, including directory-specific GPG signing information.                                                     |
| .xinitrc              | Launches Xorg and i3 when I run `startx`                                                                              |
| ssh.zip and gnupg.zip | Password protected `.ssh` and `.gnupg` folders.                                                                       |
| .Xresources           | Xorg settings like cursor size.                                                                                       |


-----

## emacs stuff
| File    | Description                                                                                             |
|---------|---------------------------------------------------------------------------------------------------------|
| init.el | My emacs config file. I was using doom emacs, but I switched to vanilla. I still use the doom modeline. |

-----

## my custom scripts
| File                                                   | Description                                                                                                                                   |
|--------------------------------------------------------|-----------------------------------------------------------------------------------------------------------------------------------------------|
| .scripts/channel_id_to_rss.sh                          | Converts a YouTube channel id to its corresponding RSS feed URL.                                                                              |
| .scripts/set-brightness-0.sh and set-brightness-100.sh | Set my monitor's brightness using DDC/CI. I run these daily with a cron job to dim my monitor at night. Better than just a blue light filter. |

-----

## i3 stuff
I use I3 with I3blocks. Blocks come from various repositories, and there are some custom blocks as well.
| File              | Description                                                                                                                                                           |
|-------------------|-----------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| .i3/config        | The main i3 config                                                                                                                                                    |
| .i3blocks.conf    | The i3 blocks config                                                                                                                                                  |
| .scripts/i3blocks | i3blocks blocklets, including [i3blocks-contrib](https://github.com/vivien/i3blocks-contrib) and [i3blocks-weather](https://github.com/hirotasoshu/i3blocks-weather). |
| i3blocks-email    | i3blocks email blocklet settings                                                                                                                                      |

-----

## vivaldi css
| File                | Description                                                                                                                                               |
|---------------------|-----------------------------------------------------------------------------------------------------------------------------------------------------------|
| vivaldi_css         | CSS for the vivaldi web browser, which vivaldi has a [setting to load from](https://forum.vivaldi.net/topic/37802/css-modifications-experimental-feature) |
| vimium-options.json | Colemak settings for the vimium browser extension. It gives vim-like keybindings for navigation in the browser.                                           |

# Gentoo setup notes
I followed the [Gentoo Handbook](https://wiki.gentoo.org/wiki/Handbook:AMD64) and the [Gentoo Full Disk Encryption guide](https://wiki.gentoo.org/wiki/Full_Disk_Encryption_From_Scratch_Simplified) to get Gentoo running on my machine with full-disk encryption.

I’m using UEFI to boot. I have a grub partition, a boot partition, and an LVM partition with logical volumes for `/` and for `/home`. I didn’t bother with a third logical volume for `/var`. I’m just using a swapfile rather than a whole swap partition. Keeping it simple.

I just used `genkernel all` for generating the kernel.

To avoid a bug with the distro periodically crashing, I had to add the boot parameters `processor.max_cstate=0`, `intel_idle.max_cstate=0`, and `idle=poll` in my grub config.

I installed `app-admin/sysklogd` for logging.

## Internet service
```
rc-update add dhcpcd default
rc-service dhcpcd start
```

## Install & configure sudo
```bash
emerge --ask app-admin/sudo
```

Then, `visudo /etc/sudoers` and add:
```bash
Defaults: taylor timestamp_timeout=-1
%wheel ALL=(ALL) ALL
```
## Install and configure git
```bash
emerge –ask dev-vcs/git
git config --global user.name "Taylor G. Lunt"
git config --global user.email taylor@taylor.gl
```

## Clone this dotfiles repo
```bash
cd ~/.build
git clone git@github.com:taylor-gl/dotfiles.git
```
Then copy the dotfiles, including `.i3` and `.i3blocks.conf` for i3, and `.bashrc` for git. Later, when dropbox is up and running, we can symlink dotfiles like:
```bash
ln -s ~/Dropbox/dotfiles/.Xresources ~/.Xresources
ln -s ~/Dropbox/dotfiles/.xinitrc ~/.xinitrc
ln -s ~/Dropbox/dotfiles/.bashrc
ln -s ~/Dropbox/dotfiles/.i3 ~/.i3
ln -s ~/Dropbox/dotfiles/.i3blocks.conf ~/.i3blocks.conf
ln -s ~/Dropbox/dotfiles/.gitconfig ~/.gitconfig
ln -s ~/Dropbox/dotfiles/.scripts ~/.scripts
ln -s ~/Dropbox/dotfiles/.alacritty.yml ~/.alacritty.yml
```

## GPG and SSH keys
Copy the contents of the password-protected `gnupg.zip` to `.gnupg`.
Copy the contents of the password-protected `ssh.zip` to `.ssh`.

## Install software
To manually change USE flags, edit `/etc/portage/make.conf`. Some use flags to consider are: `X elogind -systemd nvidia pulseaudio emacs webp xinerama cups gtk`.

When USE changes are necessary to procede, run `etc-update`.

When a package is masked, consider adding the package name to `/etc/portage/package.accept_keywords`.

Install the following software (some software, like emacs, vivaldi, layman, or nvidia-drivers may have custom USE flags worth setting first in `/etc/portage/package.use/` directory):
```bash
emerge --ask =app-editors/emacs-28.0.9999 app-admin/logrotate app-admin/sysstat app-arch/rpm app-misc/anki app-misc/colordiff app-misc/ddcutil app-misc/elasticsearch app-misc/screenfetch app-misc/sl app-misc/trash-cli app-office/libreoffice app-portage/eix app-portage/gentoolkit app-portage/layman app-text/evince app-text/tree dev-db/postgresql dev-db/postgis dev-lang/erlang dev-lang/elixir dev-python/keyring gnome-base/gnome-keyring lxde-base/lxappearance media-fonts/dejavu media-fonts/fontawesome media-gfx/feh media-gfx/gimp media-gfx/inkscape media-gfx/scrot media-gfx/xsane media-gfx/simple-scan media-sound/alsa-plugins media-sound/audacity media-sound/paprefs media-sound/pavucontrol media-sound/playerctl media-sound/pulseaudio net-im/discord net-libs/nodejs net-misc/dropbox net-p2p/qbittorrent net-print/cups sys-apps/lm-sensors sys-apps/lsd sys-apps/the_silver_searcher sys-fs/inotify_tools www-servers/nginx x11-apps/xkill x11-drivers/nvidia-drivers x11-misc/i3blocks x11-misc/rofi x11-misc/qt5ct x11-misc/xclip x11-terms/alacritty x11-themes/gtk-engines-murrine x11-wm/i3-gaps

npm install -g tldr

layman -a jorgicio
layman -a guru
layman -a steam-overlay
layman -a wayland-desktop

emerge --sync

emerge –ask =net-vpn/nordvpn-3.8.7 games-action/minecraft-launcher games-util/steam-launcher games-util/steam-meta x11-themes/bibata-cursor-theme
/usr/bin/steam
```

Make some directories:
```bash
mkdir ~/Screenshots
mkdir ~/p2p
mkdir -p /var/spool/lpd
mkdir -p /usr/lib64/cups/filter
```

## Configure lm_sensors
```bash
/usr/sbin/sensors-detect
etc-update
rc-service lm_sensors start
rc-update add lm_sensors default
```

## Configure inotify
Add to `/etc/sysctl.conf`:
```
fs.inotify.max_user_watches=524288
```

## Configure nordvpn
```bash
rc-service nordvpnd start
rc-update add nordvpnd default
nordvpn login
```

## Setup Xorg
First, set up Nvidia graphics card with the [Gentoo Nvidia guide](https://wiki.gentoo.org/wiki/NVIDIA/nvidia-drivers#Configuration). I use the `nvidia` driver, not `nouveau`.
Follow the [Gentoo Xorg Guide](https://wiki.gentoo.org/wiki/Xorg/Guide) to get Xorg running.
Run `startx` to test.

## Setup multiple monitors
### layout and 144hz
Use `nvidia-settings` to set up monitors.
### ddcutil for controlling brightness
```bash
mkdir /etc/modules-load.d/
echo i2c-dev | sudo tee -a /etc/modules-load.d/i2c.conf
modprobe i2c-dev
groupadd –system i2c
usermod -G i2c -a taylor
```
Then make a file `/etc/udev/rules.d/60-i2c-tools.rules to be like:
```bash
KERNEL=="i2c-0"     , GROUP="i2c"
KERNEL=="i2c-[1-9]*", GROUP="i2c"
```

Then reboot for changes to take effect. After that, `ddcutil detect` should display information even when run without `sudo`.

## Setup dropbox
Set `DROPBOX_USERS="taylor"` in `/etc/conf.d/dropbox`.
```bash
rc-update add dropbox default
dropbox start
```

## Setup emacs
```bash
ln -s ~/Dropbox/dotfiles/init.el ~/.emacs.d/init.el
```
Download [Fantasque Sans Mono Nerd Font](https://github.com/ryanoasis/nerd-fonts) and Noto Sans. (They go in `.local/share/fonts`.)
Then run, in emacs, `all-the-icons-install-fonts`.

## Configure Vivaldi
Sign in to sync extensions and most settings. Vimium keybindings should be synced too, but if not, import them from `dotfiles/vimium-options.json`.

Go to `vivaldi://experiments` and tick “allow for using CSS modifications”. Then, under Appearance, select `dotfiles/vivaldi_css/` as a custom UI modifications folder. This gets rid of the top bar entirely, among other things.

Create a [Gruvbox](https://camo.githubusercontent.com/410b3ab80570bcd5b470a08d84f93caa5b4962ccd994ebceeb3d1f78364c2120/687474703a2f2f692e696d6775722e636f6d2f776136363678672e706e67) theme with the following colors, disable Apply Accent Color to Window, and enable Transparent Tabs:
```
Background: 282828
Foreground: d5c4a1
Highlight: d65d0e
Accent: 504945
```

## Setup i3
It should mostly work once the config files are copied from this repo.

To set up the email password for the email blocklet:
```bash
~/.scripts/i3blocks/i3blocks-contrib/email/email –add <my-email-address>
```
And symlink the config dir:
```bash
ln -s ~/Dropbox/dotfiles/i3blocks-email ~/.config/i3blocks-email
```

## Setup printer
```bash
gpasswd -a taylor lp
gpasswd -a taylor lpadmin
rc-service cupsd start
rc-update add cupsd default
```

Get the driver install tool [here](https://support.brother.com/g/b/downloadtop.aspx?c=ca&lang=en&prod=hll2390dw_us), and follow the instructions on the website.

You can see information about the printers at `http://localhost:631/`.

## Setup theming
```bash
cd .build
git clone git@github.com:sainnhe/gruvbox-material-gtk.git
ln -s ~/.build/gruvbox-material-gtk/themes ~/.local/share/themes
ln -s ~/.build/gruvbox-material-gtk/icons ~/.local/share/icons
cp -r /usr/share/cursors/xorg-x11/Bibata-Original-Amber /usr/share/icons
```

Set `QT_QPA_PLATFORMTHEME` environment variable to `qt5ct`, and the `XDG_CURRENT_DESKTOP` environment variable to `GNOME` in `/etc/env.d`. There may already be a file like `98qt5ct` to put this in.

Then select the icon theme and widget theme using `lxappearance`.

If cursor theme is not working, make sure the theme is `Bibata-Original-Amber` in `.Xresources`, `.icons/default/index.theme`, `.config/gtk-3.0/settings.ini`, and `.gtkrc-2.0`.

## Setup libreoffice
```
Tools -> View -> Icon style -> Breeze (dark)
```

## Setup BetterDiscord
`cd ~/.build`, then follow the manual instructions on the [BetterDiscord Github](https://github.com/bb010g/betterdiscordctl#betterdiscordctl).

To upgrade `betterdiscordctl`:
```bash
betterdiscordctl self-upgrade
```

To install BetterDiscord:
```bash
betterdiscordctl install
```

## Setup postgresql
See [PostgreSQL Quickstart Guide](https://wiki.gentoo.org/wiki/PostgreSQL/QuickStart).
