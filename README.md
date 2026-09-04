# dotfiles

Manjaro, i3, kitty, emacs. One colour scheme, generated into every application
that will read a file.

## Burning Sun

Monochrome and rubrication. Text is one ink on one ground; structure is carried
by grey value, italic and weight rather than by hue. Vermilion is the rubric,
spent on headings, types, errors, the focused window, and nothing else.

Two variants share the palette: **dark** on `#0a0a0a` and **paper** on
`#ede8e0`, matching taylor.gl. They turn over on the clock (07:30 and 22:00,
from cron) and on demand from a button in the i3 bar.

Everything lives in [`theme/`](theme/). Two base16 scheme files are the source
of truth; a dependency-free renderer expands them through mustache templates
into real configs, committed so a fresh checkout is already themed. See
[`theme/README.md`](theme/README.md) for the palette, the templates, and the
places where colour is deliberately kept because removing it would destroy
meaning rather than noise.

```sh
theme/build.sh                        # after editing a scheme or template
~/.scripts/switch-to-dark-theme.sh    # apply (also runs from cron at 22:00)
~/.scripts/switch-to-light-theme.sh   # apply (also runs from cron at 07:30)
```

Applications that cannot read a colour file are switched by those scripts
instead: GTK, Obsidian, Claude Code, and a running emacs over `emacsclient`.

## Layout

| Path | |
|---|---|
| `theme/` | The colour scheme and its generator |
| `emacs/` | `init.el`, `early-init.el`, and the generated emacs themes |
| `.i3/`, `.i3blocks.conf` | Window manager and status bar |
| `kitty/`, `rofi/`, `lazygit/` | Terminal, launcher, git TUI |
| `.scripts/` | Theme switching, brightness, bar blocks, odds and ends |
| `.bashrc`, `.gitconfig`, `.dircolors` | Shell and git |
| `.xinitrc`, `.xprofile`, `.Xmodmap` | X session, cursor, hyper key |
| `old/` | Retired configs, kept for reference, ignored by git |

Deployment is by symlink into `$HOME` or `~/.config`. Emacs is the exception:
three files are linked individually into `~/.emacs.d`.

## Fonts

Iosevka throughout (monospace), Aile for the bar and
launcher, Etoile for prose in emacs.

## The bar

Beyond the usual load and temperature blocks:

- **Theme** — the current variant, as an eclipse ring or a sun. Click to flip
  the whole desktop. Refreshed by signal, so a change driven by cron shows up
  immediately rather than at the next poll.
- **Email** — unread Proton mail through Proton Mail Bridge. Silent when there
  is nothing unread. Needs `PROTON_BRIDGE_USER` and `PROTON_BRIDGE_PASS` in
  `~/.secrets`; both come from the Bridge window, and the password is the one
  Bridge generates, not the Proton account password.

## Secrets

`~/.secrets`, `.ssh/` and `.gnupg/` live in this directory but are ignored by
git and have never been committed.
