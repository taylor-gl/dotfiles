#!/usr/bin/env python3
"""i3blocks: unread count from Proton Mail, via Proton Mail Bridge.

The upstream i3blocks-contrib `email` block could not talk to Bridge: it uses
imaplib.IMAP4_SSL, i.e. implicit TLS, while Bridge listens on 127.0.0.1:1143
with STARTTLS and a self-signed certificate. Hence this rather than a patch to
a vendored script that would be overwritten on its next update.

Certificate verification is disabled deliberately. Bridge mints its own cert
and the connection never leaves the loopback interface, so there is nothing a
CA check could defend against here.

Credentials come from ~/.secrets (gitignored, already sourced by .bashrc):

    export PROTON_BRIDGE_USER=you@example.com
    export PROTON_BRIDGE_PASS=<the bridge password, not your Proton password>

Both are shown in the Proton Mail Bridge window under Mailbox details. With
either missing the block prints nothing at all rather than an error, so a
fresh machine gets a quiet bar instead of a broken one.
"""

import os
import re
import ssl
import subprocess
import sys

HOST = "127.0.0.1"
PORT = 1143
SECRETS = os.path.expanduser("~/.secrets")
MAIL_CLIENT = "betterbird"


def read_secret(name):
    """Pull one `export NAME=value` out of ~/.secrets without sourcing it."""
    try:
        with open(SECRETS) as f:
            body = f.read()
    except OSError:
        return None
    m = re.search(
        r"^\s*(?:export\s+)?%s=[\"']?([^\"'\n]+)" % re.escape(name),
        body,
        re.M,
    )
    return m.group(1).strip() if m else None


def xres(key, fallback):
    """Read a colour back out of ~/.Xresources so the block follows the theme."""
    try:
        out = subprocess.run(
            ["xrdb", "-query"], capture_output=True, text=True, timeout=2
        ).stdout
    except (OSError, subprocess.SubprocessError):
        return fallback
    for line in out.splitlines():
        if line.startswith(key + ":"):
            return line.split()[-1]
    return fallback


def unread_count(user, password):
    import imaplib

    ctx = ssl.create_default_context()
    ctx.check_hostname = False
    ctx.verify_mode = ssl.CERT_NONE

    box = imaplib.IMAP4(HOST, PORT, timeout=8)
    try:
        box.starttls(ctx)
        box.login(user, password)
        box.select("INBOX", readonly=True)
        status, data = box.search(None, "UNSEEN")
        if status != "OK":
            return None
        return len(data[0].split())
    finally:
        try:
            box.logout()
        except Exception:
            pass


def main():
    # Any click opens the mail client.
    if os.environ.get("BLOCK_BUTTON", "0") != "0":
        subprocess.Popen(
            ["setsid", MAIL_CLIENT],
            stdout=subprocess.DEVNULL,
            stderr=subprocess.DEVNULL,
            start_new_session=True,
        )

    user = read_secret("PROTON_BRIDGE_USER")
    password = read_secret("PROTON_BRIDGE_PASS")
    if not user or not password:
        return  # not configured yet; stay silent

    try:
        n = unread_count(user, password)
    except Exception:
        # Bridge restarting, asleep, or offline. A dim mark beats an error, and
        # beats a stale count that looks live.
        print('<span foreground="%s">·</span>' % xres("*i3wm.base3", "#5f5a52"))
        return

    if not n:
        return  # nothing unread: show nothing

    ember = xres("*i3wm.ember", "#ff4a00")
    print('<span foreground="%s">%d</span>' % (ember, n))


if __name__ == "__main__":
    main()
