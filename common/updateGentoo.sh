#!/bin/sh

set -xe

test -w /usr/portage && emerge --sync -q
emerge -q -g world

touch /tmp/reboot.todo
