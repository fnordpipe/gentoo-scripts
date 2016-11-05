#!/bin/sh

set -e

REPODIR="/var/lib/repo"
RSYNCDIR="/var/lib/rsync"

# push distfiles to repo server

OVERLAYRELEASE="${REPODIR}/overlay/releases/amd64/autobuilds"
OVERLAYSNAPSHOT="${REPODIR}/overlay/snapshots"

GENTOORELEASE="${REPODIR}/gentoo/releases/amd64/autobuilds"
GENTOOSNAPSHOT="${REPODIR}/gentoo/snapshots"

mkdir -p \
  ${OVERLAYRELEASE} ${OVERLAYRELEASE}/${BUILDNUMBER}/headless \
  ${OVERLAYSNAPSHOT} \
  ${GENTOORELEASE} ${GENTOORELEASE}/${BUILDNUMBER}/hardened \
  ${GENTOOSNAPSHOT}

echo "copy distfiles..."
cp -r \
  ./deploy/packages \
  ${OVERLAYRELEASE}/${BUILDNUMBER}/headless/packages

cp \
  ./deploy/overlay-stage3-amd64-headless.tar.bz2 \
  ${OVERLAYRELEASE}/${BUILDNUMBER}/headless/stage3-amd64-headless.tar.bz2

cp \
  ./deploy/overlay-portage.tar.bz2 \
  ${OVERLAYSNAPSHOT}/portage-${BUILDNUMBER}.tar.bz2

cp \
  ./deploy/gentoo-stage3-amd64-hardened.tar.bz2 \
  ${GENTOORELEASE}/${BUILDNUMBER}/hardened/stage3-amd64-hardened.tar.bz2

cp \
  ./deploy/gentoo-portage.tar.bz2 \
  ${GENTOOSNAPSHOT}/portage-${BUILDNUMBER}.tar.bz2

echo "symlink new latest..."
ln -snf ${BUILDNUMBER} ${OVERLAYRELEASE}/latest
ln -snf portage-${BUILDNUMBER}.tar.bz2 ${OVERLAYSNAPSHOT}/portage-latest.tar.bz2

ln -snf ${BUILDNUMBER} ${GENTOORELEASE}/latest
ln -snf portage-${BUILDNUMBER}.tar.bz2 ${GENTOOSNAPSHOT}/portage-latest.tar.bz2

rm -rf $(ls -rd ${OVERLAYRELEASE}/* | grep -v ${OVERLAYRELEASE}/latest | tail -n +3) || :
rm -rf $(ls -rd ${OVERLAYSNAPSHOT}/* | grep -v ${OVERLAYSNAPSHOT}/portage-latest.tar.bz2 | tail -n +3) || :

rm -rf $(ls -rd ${GENTOORELEASE}/* | grep -v ${GENTOORELEASE}/latest | tail -n +3) || :
rm -rf $(ls -rd ${GENTOOSNAPSHOT}/* | grep -v ${GENTOOSNAPSHOT}/portage-latest.tar.bz2 | tail -n +3) || :

# update rsync tree

OVERLAYRSYNC="${RSYNCDIR}/overlay/${BUILDNUMBER}/portage"
GENTOORSYNC="${RSYNCDIR}/gentoo/${BUILDNUMBER}/portage"

mkdir -p \
  ${OVERLAYRSYNC} \
  ${GENTOORSYNC}

echo "copy portage tree..."
tar xjf ${OVERLAYSNAPSHOT}/portage-latest.tar.bz2 --no-same-owner --no-same-permissions --strip-components=1 -C ${OVERLAYRSYNC}
tar xjf ${GENTOOSNAPSHOT}/portage-latest.tar.bz2 --no-same-owner --no-same-permissions --strip-components=1 -C ${GENTOORSYNC}

echo "symlink new latest..."
ln -snf ${RSYNCDIR}/overlay/${BUILDNUMBER} ${RSYNCDIR}/overlay/latest
ln -snf ${RSYNCDIR}/gentoo/${BUILDNUMBER} ${RSYNCDIR}/gentoo/latest

echo "delete old distfiles"
rm -rf $(ls -rd ${RSYNCDIR}/overlay/* | grep -v ${RSYNCDIR}/overlay/latest | tail -n +3) || :
rm -rf $(ls -rd ${RSYNCDIR}/gentoo/* | grep -v ${RSYNCDIR}/gentoo/latest | tail -n +3) || :
