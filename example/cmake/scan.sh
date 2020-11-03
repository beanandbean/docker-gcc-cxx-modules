#!/bin/bash
[[ `cat $1` =~ (^|'
')[[:space:]]*export[[:space:]]+module[[:space:]]+([A-Za-z0-9_.:]+)[[:space:]]*';' ]] && echo ${BASH_REMATCH[2]} $2/${BASH_REMATCH[2]}.gcm || exit 0;