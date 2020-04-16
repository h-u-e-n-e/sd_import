#!/bin/bash

scriptdir=$(dirname ${0})
scriptname=$(basename ${0})
logfile=/var/log/scripts/${USER}/$(date -I)_${scriptname}.log
src=/mnt/sd/DCIM/100D5600
pic=/srv/dev-disk-by-label-data/intern/fotos
dst=${pic}/$(date +%Y)/$(date -I)

log() {
  lvl=${1}
  shift
  echo "$(date -Iseconds) - ${lvl} - ${@}" >> ${logfile}
}

cleanup() {
  log "INFO" "cleaning up - unmounting sd card"
  umount /dev/sdf1
  exit ${?}
}

fail() {
  log "ERROR" "${@}"
  cleanup
  exit ${rtc}
}

checkRTC() {
  rtc=${?}
  [[ 0 -eq ${rtc} ]]
}

log "INFO" "card inserted"
mount /dev/sdf1 /mnt/sd
checkRTC && log "INFO" "card mounted" || fail "could not mount card"
log "INFO" "checking for pictures"

for f in ${src}/DSC*; do
    [ -e "$f" ] || cleanup
    break
done

log "INFO" "moving pics to share"
[[ -d ${dst} ]] && { dst=${pic}/$(date +%Y)/$(date +%Y-%m-%d-%H-%M-%S); mkdir ${dst}; } || mkdir -p ${dst}
checkRTC || fail "could not create target dir"
find ${src} -type f -name "DSC*" -exec mv {} ${dst}/ \;
checkRTC && log "INFO" "pics moved successfully" || fail "could not move pictures"
cleanup
