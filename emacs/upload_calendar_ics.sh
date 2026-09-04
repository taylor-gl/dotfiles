#!/usr/bin/env bash

set -Eeoux pipefail

/usr/local/bin/emacs --batch --load /home/taylor/.emacs.d/init.el --eval "(taylor-gl/org-icalendar-export)"

mv /home/taylor/org.ics /tmp/zozkb5wfp2m67087mf0pycdbvbldpfvkwrp30mq1bzzzn43rl6tguf0zzk8qdova.ics

# ensure I have a key has a key in /home/taylor/.ssh/taylor.gl, which has been copied to the server
# if not, then run:
# providing name /home/taylor/.ssh/taylor.gl:
# ssh-keygen -t rsa
# ssh-copy-id -i /home/taylor/.ssh/taylor.gl root@taylor.gl
/usr/bin/scp -i /home/taylor/.ssh/taylor.gl /tmp/zozkb5wfp2m67087mf0pycdbvbldpfvkwrp30mq1bzzzn43rl6tguf0zzk8qdova.ics root@taylor.gl:/root/taylor.gl/priv/static/static

# The file can then be fetched from https://taylor.gl/static/zozkb5wfp2m67087mf0pycdbvbldpfvkwrp30mq1bzzzn43rl6tguf0zzk8qdova.ics
# At least, once the server is updated
# I have a cron job running on the server like:

#cd /root/taylor.gl

#/root/taylor.gl/priv/secret/assemble_release.sh

#systemctl restart blog_new.service
