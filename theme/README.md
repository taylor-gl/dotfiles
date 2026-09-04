# Burning Sun

One colour scheme, in two variants, rendered into every application's config.

The palette is the website's (taylor.gl) four values — `--bg`, `--ink`,
`--line`, `--ember` — restated in [base16](https://github.com/tinted-theming)
role slots so the desktop and the site cannot drift apart.

## The idea

**Monochrome and rubrication.** Text is one ink on one ground. Structure is
carried by grey value, italic and weight — not by hue. Vermilion is the
rubric: spent on types, headings, errors and the focused window, and on
nothing else.

### Where colour is information

A few places keep a distinction, because removing it destroys meaning rather
than noise. All of them are drawn with the scheme's own values:

- **Diffs** (terminal, magit, diff-mode, Obsidian) — a deletion burns, an
  addition is simply more ink. Identical logic everywhere.
- **Three-way merges** (smerge, ediff) — ink-versus-ember has two states and a
  conflict has three, so these separate by background value as well.
- **diff-hl fringe** — the margin is too narrow for text, so a solid block of
  colour does the whole job.
- **Rainbow delimiters** — nesting depth is genuinely easier to read in hue.
- **Severity ramps** (hl-todo, callouts, compilation) — already an ordering,
  so they map onto ember -> grey rather than onto separate hues.

## Layout

```
schemes/          the source of truth — edit these
  burning-sun-dark.yaml
  burning-sun-paper.yaml
templates/        mustache, one per application
  xresources.mustache        custom  — emits doom names for .i3/config
  emacs-doom-theme.mustache  custom  — def-doom-theme
  kitty.mustache             custom  — uses the ANSI carve-out
  rofi.mustache              custom
  lazygit.mustache           custom
  obsidian.mustache          custom  — both variants in one theme
  gtk.mustache               custom  — GTK3 + GTK4/libadwaita named colours
  claude-code.mustache       custom  — ~/.claude/themes/<slug>.json
render.py         ~200 lines, python3 stdlib only
build.sh          renders everything into out/
out/{dark,paper}/ generated — committed, so a fresh checkout is already themed
wallpaper/
```

## Usage

```sh
./build.sh                        # after editing a scheme or template
~/.scripts/switch-to-dark-theme.sh    # apply (also runs from cron at 22:00)
~/.scripts/switch-to-light-theme.sh   # apply (also runs from cron at 07:30)
```

`build.sh` also copies themes into `emacs/themes/` and `~/.claude/themes/`, installs the Obsidian theme into the vault, dims the
wallpaper for the dark variant, and splices lazygit's block into
`lazygit/config.yml` between markers.

Applications that cannot read a file for their colours are switched by the
switch scripts instead: GTK (`~/.config/gtk-{3,4}.0/gtk.css`), Obsidian
(`appearance.json`), Claude Code (one theme file whose contents are swapped,
plus the `theme` key in `~/.claude/settings.json`, which outranks
`~/.claude.json`) and emacs (over `emacsclient`).

## Why not tinty

[tinty](https://github.com/tinted-theming/tinty) is the official base16 CLI and
is the right tool if you want the 250-scheme catalogue. It was not adopted here
because the two configs that matter most — i3 (which consumes doom-style
variable names via `set_from_resource`) and emacs (`def-doom-theme`) — need
custom templates regardless, and `switch-to-*-theme.sh` was already doing
exactly what tinty's hooks do. The scheme files follow the base16 spec, so
adopting tinty later is a matter of writing a `config.toml` and changing
nothing else.

## Deriving another variant

Add a `schemes/burning-sun-<name>.yaml` and run `build.sh`. Everything
downstream follows. Any of the 250+ stock base16 schemes can be dropped in the
same way, though the templates assume this scheme's rubrication logic — a
colourful scheme will render, but it will not look the way its author intended.

## Contrast

Most text pairs clear WCAG AA against their own background, but this is not a
constraint the scheme is held to. The rubric is `#ff4a00` in both variants
because matching the site exactly matters more here than the ratio does — on
paper that comes to 2.76:1, deliberately.
