#!/bin/sh

set -e

source /etc/httpPublish.cfg

BN=${BUILDNUMBER:-$(date +"%s")}

httpUser=${httpUser:-dirlisting}
httpHost=${httpHost:-127.0.0.1}

echo "prepare target system..."
ssh -l ${httpUser} ${httpHost} " \
  mkdir -p \
    ~/htdocs/fnordpipe/releases/amd64/autobuilds/${BN}/headless \
    ~/htdocs/fnordpipe/snapshots \
    ~/htdocs/gentoo/releases/amd64/autobuilds/${BN}/hardened \
    ~/htdocs/gentoo/snapshots \
  "

echo "publish packages..."
rsync -aze ssh \
  ./deploy/packages \
  ${httpUser}@${httpHost}:~/htdocs/fnordpipe/releases/amd64/autobuilds/${BN}/headless

echo "publish stage tarballs..."
scp ./deploy/overlay-stage3-amd64-headless.tar.bz2 \
  ${httpUser}@${httpHost}:~/htdocs/fnordpipe/releases/amd64/autobuilds/${BN}/headless/stage3-amd64-headless.tar.bz2

scp ./deploy/gentoo-stage3-amd64-hardened.tar.bz2 \
  ${httpUser}@${httpHost}:~/htdocs/gentoo/releases/amd64/autobuilds/${BN}/hardened/stage3-amd64-hardened.tar.bz2

echo "publish portage tarballs..."
scp ./deploy/overlay-portage.tar.bz2 \
  ${httpUser}@${httpHost}:~/htdocs/fnordpipe/snapshots/portage-${BN}.tar.bz2

scp ./deploy/gentoo-portage.tar.bz2 \
  ${httpUser}@${httpHost}:~/htdocs/gentoo/snapshots/portage-${BN}.tar.bz2

echo "tag new latest version..."
ssh -l ${httpUser} ${httpHost} " \
  ln -snf ${BN} ~/htdocs/fnordpipe/releases/amd64/autobuilds/latest && \
  ln -snf portage-${BN}.tar.bz2 ~/htdocs/fnordpipe/snapshots/portage-latest.tar.bz2 && \
  ln -snf ${BN} ~/htdocs/gentoo/releases/amd64/autobuilds/latest && \
  ln -snf portage-${BN}.tar.bz2 ~/htdocs/gentoo/snapshots/portage-latest.tar.bz2
"

echo "cleanup old versions..."
ssh -l ${httpUser} ${httpHost} ' \
  rm -rf $(ls -d --sort=time ~/htdocs/fnordpipe/releases/amd64/autobuilds/* | grep -v ~/htdocs/fnordpipe/releases/amd64/autobuilds/latest | tail -n +3) || : && \
  rm -rf $(ls -d --sort=time ~/htdocs/fnordpipe/snapshots/* | grep -v ~/htdocs/fnordpipe/snapshots/portage-latest.tar.bz2 | tail -n +3) || : && \
  rm -rf $(ls -d --sort=time ~/htdocs/gentoo/releases/amd64/autobuilds/* | grep -v ~/htdocs/gentoo/releases/amd64/autobuilds/latest | tail -n +3) || : && \
  rm -rf $(ls -d --sort=time ~/htdocs/gentoo/snapshots/* | grep -v ~/htdocs/gentoo/snapshots/portage-latest.tar.bz2 | tail -n +3) || :
'
