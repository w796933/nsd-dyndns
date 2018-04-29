#!/usr/local/bin/bash

. /etc/dyndns.conf

REQ_IP=$(/usr/bin/grep ${PASS} ${LOG} | /usr/bin/tail -1 | /usr/bin/awk '{print $2}')

if [ -f $LAST_IP_FILE ]; then
	LAST_IP=$(/bin/cat $LAST_IP_FILE)
fi

if [[ $LAST_IP != $REQ_IP ]]; then
	/bin/cat $ZONEFILE | /usr/bin/sed "4s/.*/${TIMESTAMP}/" | /usr/bin/sed "s/^${SUBDOMAIN}.*/${SUBDOMAIN} IN A ${REQ_IP}/" > $ZONEFILE
	/etc/rc.d/nsd reload
	/bin/echo $REQ_IP > $LAST_IP_FILE
	/bin/echo "update"
fi
