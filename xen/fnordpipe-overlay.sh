#!/bin/bash

set -e

iface="eth0"

while true; do
  case "${1}" in
    --hostname*) name=${1/--hostname=}; shift 1;;
    --dev*)   dev=${1/--dev=}; shift 1;;
    --iface*) iface=${1/--iface=} shift 1;;
    --)       shift 1; break;;
    *)        break;;
  esac
done

test -z "${rootfs}" && rootfs=$(mktemp -d)

if [ -n "${dev}" ]; then
  curl -sL http://distfiles.fnordpipe.org/fnordpipe/releases/amd64/autobuilds/latest/headless/stage3-amd64-headless.tar.bz2 | tar xjpf - -C ${rootfs}

  curl -sL http://git.fnordpipe.org/gentoo/scripts.git/plain/chroot/env.sh > ${rootfs}/env.sh
  chmod 0744 ${rootfs}/env.sh

  install -d -m 0700 ${rootfs}/root/.ssh
  test -f /root/.ssh/authorized_keys && install -m 0600 /root/.ssh/authorized_keys ${rootfs}/root/.ssh/authorized_keys

  echo "config_${iface}=\"dhcp\"" > ${rootfs}/etc/conf.d/net
  echo "hostname=\"${name}\"" > ${rootfs}/etc/conf.d/hostname
  echo "127.0.0.1 ${name} localhost" > ${rootfs}/etc/hosts
  sed -i '/^c1:12345.*/i c0:2345:respawn:/sbin/agetty 38400 hvc0 linux' ${rootfs}/etc/inittab

  ln -snf net.lo ${rootfs}/etc/init.d/net.${iface}
  ln -snf /etc/init.d/net.${iface} ${rootfs}/etc/runlevels/default/net.${iface}
  ln -snf /etc/init.d/sshd ${rootfs}/etc/runlevels/default/sshd

  chroot ${rootfs} /env.sh emerge --sync
  chroot ${rootfs} /env.sh emerge -qg net-misc/bridge-utils

  # dear future-self, fix the fucking kernel issue
  cp -rp /lib/modules ${rootfs}/lib/
  cp -rp /lib/firmware ${rootfs}/lib/

  rm -f ${rootfs}/env.sh

  mkfs.ext4 -F ${dev} -d ${rootfs}
  rm -rf ${rootfs}
fi
