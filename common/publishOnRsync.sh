#!/bin/sh

set -e

test -f /etc/rsyncPublish.cfg &&
  source /etc/rsyncPublish.cfg

BN=${BUILDNUMBER:-$(date +"%s")}

rsyncUser=${rsyncUser:-rsync}
rsyncHost=${rsyncHost:-127.0.0.1}

echo "prepare target system..."
ssh -l ${rsyncUser} ${rsyncHost} " \
  mkdir -p \
    ~/fnordpipe-portage/${BN} \
    ~/gentoo-portage/${BN} \
"

echo "publish portage tree..."
cat ./deploy/overlay-portage.tar.bz2 | \
  ssh -l ${rsyncUser} ${rsyncHost} " \
    tar xjf - --no-same-owner --no-same-permissions --strip-components=1 -C ~/fnordpipe-portage/${BN} && \
    date > ~/fnordpipe-portage/${BN}/metadata/timestamp && \
    date +'%a, %d %b %Y %T %z' > ~/fnordpipe-portage/${BN}/metadata/timestamp.chk \
  "

cat ./deploy/gentoo-portage.tar.bz2 | \
  ssh -l ${rsyncUser} ${rsyncHost} " \
    tar xjf - --no-same-owner --no-same-permissions --strip-components=1 -C ~/gentoo-portage/${BN} \
  "

echo "tag new latest version..."
ssh -l ${rsyncUser} ${rsyncHost} " \
  ln -snf ${BN} ~/fnordpipe-portage/latest && \
  ln -snf ${BN} ~/gentoo-portage/latest \
"

echo "cleanup old versions..."
ssh -l ${rsyncUser} ${rsyncHost} ' \
  rm -rf $(ls -d --sort=time ~/fnordpipe-portage/* | grep -v ~/fnordpipe-portage/latest | tail -n +3) || : && \
  rm -rf $(ls -d --sort=time ~/gentoo-portage/* | grep -v ~/gentoo-portage/latest | tail -n +3) || : \
'
