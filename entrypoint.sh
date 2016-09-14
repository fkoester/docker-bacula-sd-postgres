#! /bin/bash

die() {
    echo >&2 "[`date +'%Y-%m-%d %T'`] $@"
    exit 1
}

log() {
  if [[ "$@" ]]; then echo "[`date +'%Y-%m-%d %T'`] $@";
  else echo; fi
}

BACULA_SD_CONFIG="/etc/bacula/bacula-sd.conf"
BACULA_SD_PID_FILE="/var/run/bacula-sd.9103.pid"
BACULA_SD_COMMAND="/usr/sbin/bacula-sd -c ${BACULA_SD_CONFIG}"

/usr/local/bin/create_dhparam.sh || die "Failed to generate dhparam"

rm -fv ${BACULA_SD_PID_FILE} || die "Failed to remove stale PID file"

# Test configuration file first
${BACULA_SD_COMMAND} -t || die "Configuration test failed"

# Launch bacula-sd
${BACULA_SD_COMMAND} || die "Failed to start bacula-sd"

# Check if config or certificates were changed and restart if necessary
while inotifywait -q -r --exclude '\.git/' -e modify -e create -e delete $BACULA_SD_CONFIG /etc/letsencrypt; do
  # TODO Reload SD
done
