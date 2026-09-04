#!/usr/bin/env python3
"""Render a base16 scheme through a mustache template.

Implements the subset of mustache the base16 templates actually use: plain
variable substitution plus the {{#section}}...{{/section}} loops that a couple
of the vendored templates wrap their output in. Deliberately no PyYAML — the
scheme files are flat enough to parse with the standard library, which keeps
the whole theme pipeline dependency-free.

Variables exposed to templates, for each of base00..base0F:

    {{base00-hex}}      0a0a0a          {{base00-hex-bgr}}  0a0a0a
    {{base00-hex-r}}    0a              {{base00-rgb-r}}    10
    {{base00-hex-g}}    0a              {{base00-rgb-g}}    10
    {{base00-hex-b}}    0a              {{base00-rgb-b}}    10
    {{base00-dec-r}}    0.039216        (etc.)

plus {{scheme-name}}, {{scheme-slug}}, {{scheme-author}}, {{scheme-variant}},
{{scheme-system}}, and everything under `extras:` as {{rainbow-0}}..{{rainbow-5}}
and {{ansi-red}}, {{ansi-bright-red}}, and so on.
"""

import re
import sys
from pathlib import Path

# --- scheme parsing -------------------------------------------------------


def parse_scheme(path):
    """Parse the flat subset of YAML the scheme files use.

    Handles top-level `key: "value"`, one level of nesting under `palette:`
    and `extras:`, a second level under `extras.ansi`, and `- "item"` lists.
    Comments and blank lines are dropped.
    """
    top = {}
    stack = [(-1, top)]
    list_target = None

    for raw in path.read_text().splitlines():
        line = _strip_comment(raw)
        if not line.strip():
            continue

        indent = len(line) - len(line.lstrip())
        body = line.strip()

        if body.startswith("- "):
            if list_target is None:
                raise ValueError(f"{path}: list item outside a list: {body}")
            list_target.append(_unquote(body[2:]))
            continue

        list_target = None
        while stack and indent <= stack[-1][0]:
            stack.pop()
        parent = stack[-1][1]

        key, _, value = body.partition(":")
        key, value = key.strip(), value.strip()

        if value == "":
            child = []
            # `rainbow:` is the only list; everything else nests as a mapping.
            if key != "rainbow":
                child = {}
            else:
                list_target = child
            parent[key] = child
            if isinstance(child, dict):
                stack.append((indent, child))
        else:
            parent[key] = _unquote(value)

    return top


def _strip_comment(line):
    """Drop a trailing `#` comment, ignoring any `#` inside quotes.

    Necessary because every value in these files is a colour, so `#` appears
    both as a comment marker and as the first character of the data.
    """
    quote = None
    for i, ch in enumerate(line):
        if quote:
            if ch == quote:
                quote = None
        elif ch in "\"'":
            quote = ch
        elif ch == "#":
            return line[:i].rstrip()
    return line.rstrip()


def _unquote(s):
    s = s.strip()
    if len(s) >= 2 and s[0] == s[-1] and s[0] in "\"'":
        return s[1:-1]
    return s


# --- variable expansion ---------------------------------------------------


def slugify(name):
    return re.sub(r"[^a-z0-9]+", "-", name.lower()).strip("-")


def colour_vars(prefix, hex_value):
    h = hex_value.lstrip("#").lower()
    r, g, b = h[0:2], h[2:4], h[4:6]
    out = {
        f"{prefix}-hex": h,
        f"{prefix}-hex-bgr": b + g + r,
        f"{prefix}-hex-r": r,
        f"{prefix}-hex-g": g,
        f"{prefix}-hex-b": b,
    }
    for name, part in (("r", r), ("g", g), ("b", b)):
        value = int(part, 16)
        out[f"{prefix}-rgb-{name}"] = str(value)
        out[f"{prefix}-dec-{name}"] = f"{value / 255:.6f}"
    return out


def _mix(a, b, t):
    """Blend two hex colours in linear-light, which keeps a grey ramp even.

    Mixing in raw sRGB bunches the midtones toward the dark end and makes an
    evenly-numbered ramp look lopsided; going through linear light and back
    gives steps that actually read as equal.
    """

    def to_linear(c):
        c /= 255
        return c / 12.92 if c <= 0.04045 else ((c + 0.055) / 1.055) ** 2.4

    def to_srgb(c):
        c = 12.92 * c if c <= 0.0031308 else 1.055 * c ** (1 / 2.4) - 0.055
        return round(max(0.0, min(1.0, c)) * 255)

    a, b = a.lstrip("#"), b.lstrip("#")
    out = []
    for i in (0, 2, 4):
        la = to_linear(int(a[i : i + 2], 16))
        lb = to_linear(int(b[i : i + 2], 16))
        out.append(to_srgb(la + (lb - la) * t))
    return "#{:02x}{:02x}{:02x}".format(*out)


def _mix_srgb(a, b, t):
    """Blend two hex colours in plain sRGB.

    Used for the diff washes rather than `_mix`. Linear-light mixing is the
    right answer for a perceptually even ramp, but it overshoots badly at low
    ratios — a 12% blend toward the ember came out a saturated red instead of
    a hint of one. Naive sRGB interpolation is what actually looks subtle here.
    """
    a, b = a.lstrip("#"), b.lstrip("#")
    out = []
    for i in (0, 2, 4):
        ca = int(a[i : i + 2], 16)
        cb = int(b[i : i + 2], 16)
        out.append(round(ca + (cb - ca) * t))
    return "#{:02x}{:02x}{:02x}".format(*out)


def grey_ramp(palette, steps=9):
    """Sample `steps` evenly-spaced greys along base00 -> base06.

    doom-themes wants nine ramp entries (base0..base8) but base16 only defines
    seven greys, so a naive mapping has to duplicate two of them. In a theme
    where grey value carries all the structure that flattening is visible, so
    the missing steps are interpolated between the scheme's own anchors rather
    than repeated.
    """
    anchors = [palette[f"base0{i}"] for i in range(7)]
    span = len(anchors) - 1
    ramp = []
    for i in range(steps):
        pos = i / (steps - 1) * span
        lo = min(int(pos), span - 1)
        ramp.append(_mix(anchors[lo], anchors[lo + 1], pos - lo))
    return ramp


def build_context(scheme):
    ctx = {
        "scheme-name": scheme["name"],
        "scheme-slug": slugify(scheme["name"]),
        "scheme-author": scheme["author"],
        "scheme-variant": scheme["variant"],
        "scheme-system": scheme.get("system", "base16"),
    }
    dark = scheme["variant"] == "dark"
    ctx["scheme-is-dark"] = dark
    ctx["scheme-is-light"] = not dark

    # Names for the 16-colour terminal fallback, which has to invert with the
    # variant or `emacs -nw` renders the paper theme as white-on-white.
    ctx["term-bg"] = "black" if dark else "white"
    ctx["term-bg-alt"] = "brightblack" if dark else "white"
    ctx["term-fg"] = "brightwhite" if dark else "black"
    ctx["term-fg-alt"] = "white" if dark else "brightblack"

    for slot, value in scheme["palette"].items():
        ctx.update(colour_vars(slot, value))

    for i, value in enumerate(grey_ramp(scheme["palette"])):
        ctx.update(colour_vars(f"ramp-{i}", value))

    # Diff block tints, mixed toward the background so they read as a wash
    # rather than a highlight. Deletions take an ember cast, additions a
    # neutral lift toward the ink, changes the secondary rubric. Derived
    # rather than declared so both variants tint in the right direction.
    palette = scheme["palette"]
    bg, ink, ember = palette["base00"], palette["base05"], palette["base08"]
    ember2 = palette["base09"]
    for name, base, faint, weak, strong in (
        ("diff-del", ember, 0.06, 0.12, 0.28),
        ("diff-add", ink, 0.035, 0.07, 0.16),
        ("diff-mod", ember2, 0.045, 0.09, 0.20),
    ):
        ctx.update(colour_vars(f"{name}-dim", _mix_srgb(bg, base, faint)))
        ctx.update(colour_vars(f"{name}-bg", _mix_srgb(bg, base, weak)))
        ctx.update(colour_vars(f"{name}-hl", _mix_srgb(bg, base, strong)))

    # Claude Code animates a seven-stop "rainbow" gradient. Left at its
    # defaults it is the one place blue survives, so it becomes an ember-to-
    # grey sweep instead: still a gradient, still legible as motion, no hue.
    for i in range(7):
        t_ = i / 6
        ctx.update(colour_vars(f"sweep-{i}", _mix_srgb(ember, palette["base04"], t_)))
        ctx.update(colour_vars(f"sweep-{i}-lit", _mix_srgb(
            _mix_srgb(ember, palette["base04"], t_), palette["base06"], 0.45)))

    extras = scheme.get("extras", {}) or {}
    for i, value in enumerate(extras.get("rainbow", [])):
        ctx.update(colour_vars(f"rainbow-{i}", value))
    for name, value in (extras.get("ansi", {}) or {}).items():
        ctx.update(colour_vars("ansi-" + name.replace("_", "-"), value))

    return ctx


# --- mustache -------------------------------------------------------------

SECTION = re.compile(r"\{\{([#^])([\w-]+)\}\}\n?(.*?)\{\{/\2\}\}\n?", re.DOTALL)
VARIABLE = re.compile(r"\{\{\{?([\w-]+)\}?\}\}")


def render(template, ctx):
    def section(m):
        kind, key, body = m.group(1), m.group(2), m.group(3)
        truthy = bool(ctx.get(key))
        if kind == "^":
            truthy = not truthy
        return render(body, ctx) if truthy else ""

    while SECTION.search(template):
        template = SECTION.sub(section, template)

    def variable(m):
        key = m.group(1)
        if key not in ctx:
            raise KeyError(f"template references unknown variable {{{{{key}}}}}")
        return str(ctx[key])

    return VARIABLE.sub(variable, template)


def main():
    if len(sys.argv) != 3:
        sys.exit("usage: render.py <scheme.yaml> <template.mustache>")
    scheme = parse_scheme(Path(sys.argv[1]))
    sys.stdout.write(render(Path(sys.argv[2]).read_text(), build_context(scheme)))


if __name__ == "__main__":
    main()
