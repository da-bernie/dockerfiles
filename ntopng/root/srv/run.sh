#! /bin/sh
#
# Set root password and start NTOPNG instance
#
# Author:       Thomas Bendler <project@bendler-net.de>
# Date:         Sat Feb 17 21:35:23 CET 2018
#
# Release:      v1.0
#
# Prerequisite: This release needs a shell which could handle functions.
#               If shell is not able to handle functions, remove the
#               error section.
#
# ChangeLog:    v1.0 - Initial release
#

### Enable debug if debug flag is true ###
if [ -n "${NTOPNG_ENV_DEBUG}" ]; then
  set -ex
fi

### Error handling ###
error_handling() {
  if [ "${RETURN}" -eq 0 ]; then
    echo "${SCRIPT} successfull!"
  else
    echo "${SCRIPT} aborted, reason: ${REASON}"
  fi
  exit "${RETURN}"
}
trap "error_handling" EXIT HUP INT QUIT TERM
RETURN=0
REASON="Finished!"

### Default values ###
export PATH=/usr/sbin:/usr/bin:/sbin:/bin
export LC_ALL=C
export LANG=C
SCRIPT=$(basename ${0})

### Check prerequisite ###
if [ ! -f /.dockerenv ]; then RETURN=1; REASON="Not executed inside a Docker container, aborting!"; exit; fi

### Check if FRITZ box should be monitored ###
if [ -n "${NTOPNG_ENV_FRITZBOX_CAPTURE}" ]; then
  FRITZBOX_CAPTURE="true"

  ### Get FRITZ box password ###
  if [ -n "${NTOPNG_ENV_FRITZBOX_IFACE}" ]; then
    if [ "${NTOPNG_ENV_FRITZBOX_IFACE}" = "wan" ]; then
      FRITZBOX_IFACE="3-17"
    else
      FRITZBOX_IFACE="1-lan"
    fi
  fi

  ### Get FRITZ box password ###
  if [ -n "${NTOPNG_ENV_FRITZBOX_PASSWORD}" ]; then
    FRITZBOX_PASSWORD=${NTOPNG_ENV_FRITZBOX_PASSWORD}
  fi

### Get FRITZ box username ###
  if [ -n "${NTOPNG_ENV_FRITZBOX_USER}" ]; then
    FRITZBOX_PASSWORD=${NTOPNG_ENV_FRITZBOX_USER}
  fi

  ### The is the address of the FRITZ box ###
#  FRITZBOX_IP=$(nslookup fritz.box 2> /dev/null | grep dress | cut -d' ' -f3)
  FRITZBOX_IP=192.168.2.1

  FRITZBOX_SIDFILE="/tmp/fritz.sid"
  FRITZBOX_CHALLENGE=$(curl -s http://${FRITZBOX_IP}/login_sid.lua |  grep -o "<Challenge>[a-z0-9]\{8\}" | cut -d'>' -f2)
  FRITZBOX_HASH=$(perl -MPOSIX -e '
      use Digest::MD5 "md5_hex";
      my $ch_Pw = "$ARGV[0]-$ARGV[1]";
      $ch_Pw =~ s/(.)/$1 . chr(0)/eg;
      my $md5 = lc(md5_hex($ch_Pw));
      print $md5;
    ' -- "${FRITZBOX_CHALLENGE}" "${FRITZBOX_PASSWORD}")
  FRITZBOX_SID=$(curl -s "http://${FRITZBOX_IP}/login_sid.lua" -d "response=${FRITZBOX_CHALLENGE}-${FRITZBOX_HASH}" \
                      -d 'username=bernhard' | grep -o "<SID>[a-z0-9]\{16\}" | cut -d'>' -f2)
else
  FRITZBOX_CAPTURE="false"
fi

cat <<EOF

===========================================================

The dockerized NTOPNG instance is now ready for use! The web
interface is available here:

URL:                  http://${NTOPNG_ENV_HOST}/
Username:             admin
Password:             admin

FRITZ box monitoring: ${FRITZBOX_CAPTURE}
FRITZ box interface:  ${FRITZBOX_IFACE}

===========================================================

EOF

### Start REDIS instance ###
/etc/init.d/redis-server start
#redis-server /etc/redis.conf

### Start NTOPNG instance ###
# chown -R ntop:ntop /var/lib/ntopng

NTOPNG_COMMAND="/usr/bin/ntopng --dns-mode 1"

FRITZBOX_URL="http://${FRITZBOX_IP}/cgi-bin/capture_notimeout?ifaceorminor=${FRITZBOX_IFACE}&snaplen=&capture=Start&sid=${FRITZBOX_SID}"

if [ ${FRITZBOX_CAPTURE} = "true" ]; then
	echo ${FRITZBOX_URL}

  wget -qO- ${FRITZBOX_URL} | ${NTOPNG_COMMAND} -i -
else
  ${NTOPNG_COMMAND}
fi
