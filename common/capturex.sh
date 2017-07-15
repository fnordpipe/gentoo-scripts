#!/bin/bash

SEDPATTERN='s/.*\s\([[:digit:]]\{1,4\}x[[:digit:]]\{1,4\}+[[:digit:]]\{1,4\}+[[:digit:]]\{1,4\}\)\s.*/\1/g'
i=1

for respos in $(xrandr | grep -w connected | sed ${SEDPATTERN}); do
	OUTPUT[${i}]=${respos}
	echo "${i}) ${OUTPUT[${i}]}"
	i=$(expr ${i} + 1)	
done

while [ ${i} -ne 0 ]; do
	read -p 'choose screen to capture: ' c
	if [ ${c} -gt 0 ] && [ ${c} -lt ${i} ]; then
		i=0
	fi
done

test -f ${XDG_CONFIG_HOME:-~/.config}/user-dirs.dirs &&
	source ${XDG_CONFIG_HOME:-~/.config}/user-dirs.dirs

DATADIR=${XDG_DESKTOP_DIR:-$HOME/Videos}/screencapture
SCREEN=${OUTPUT[${c}]}
VS=$(echo ${SCREEN} | awk -F '+' '{ print $1 }')
POS=$(echo ${SCREEN} | awk -F '+' '{ print $2 "," $3 }')
install -d ${DATADIR}
ffmpeg -video_size ${VS} -framerate 30 -f x11grab -i :0.0+${POS} \
	-c:v libx264 -qp 0 -preset ultrafast \
	"${DATADIR}/$(date +"%Y%m%d-%H%M%S").mkv" &> /dev/null
