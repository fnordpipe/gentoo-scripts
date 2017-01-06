#!/bin/bash

set -e

iface="eth0"
iaddr="dhcp"

while true; do
  case "${1}" in
    --path*)        path=${1/--path=}; shift 1;;
    --name*)        name=${1/--name=}; shift 1;;
    --rootfs*)      rootfs=${1/--rootfs=}; shift 1;;
    --iface*)       iface=${1/--iface=}; shift 1;;
    --iaddr*)       iaddr=${1/--iaddr=}; shift 1;;
    --route*)       route=${1/--route=}; shift 1;;
    --)             shift 1; break ;;
    *)              break ;;
  esac
done

test -z "${rootfs}" && rootfs=$(mktemp -d)

install -d -m 0755 ${rootfs}
curl -sL http://distfiles.fnordpipe.org/fnordpipe/releases/amd64/autobuilds/latest/headless/stage3-amd64-headless.tar.bz2 | tar xjpf - -C ${rootfs}

install -d -m 0700 ${rootfs}/root/.ssh
test -f /root/.ssh/authorized_keys && install -m 0600 /root/.ssh/authorized_keys ${rootfs}/root/.ssh/authorized_keys

if [ -n "${iface}" ] && [ -n "${iaddr}" ] && [ -n "${route}" ]; then
  echo "config_${iface}=\"${iaddr}\"" > ${rootfs}/etc/conf.d/net
  echo "routes_${iface}=\"default via ${route}\"" >> ${rootfs}/etc/conf.d/net
fi

ln -snf net.lo ${rootfs}/etc/init.d/net.${iface}
ln -snf /etc/init.d/net.${iface} ${rootfs}/etc/runlevels/default/net.${iface}
ln -snf /etc/init.d/sshd ${rootfs}/etc/runlevels/default/sshd
