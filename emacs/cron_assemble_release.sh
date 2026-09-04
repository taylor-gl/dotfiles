#!/usr/bin/env bash

set -Eeoux pipefail

cd /root/taylor.gl

/root/taylor.gl/priv/secret/assemble_release.sh

systemctl restart blog_new.service
