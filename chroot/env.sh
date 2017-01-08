#!/bin/sh

# chroot wrapper for a clean portage environment

if [ -z "${1}" ]; then
  echo "USAGE: ${0} <cmd> [<args>] [..]"
  exit 1
fi

env-update
source /etc/profile

unset MAKEFLAGS
unset MAKELEVEL
unset MAKE_TERMOUT
unset MAKE_TERMERR

${@}
