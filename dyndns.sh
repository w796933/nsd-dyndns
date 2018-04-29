#!/usr/local/bin/bash

. /etc/dyndns.conf

REQ_IP=$(grep ${PASS} ${LOG} | tail -1 | awk '{print $2}')

if [ -f $LAST_IP_FILE ]; then
	LAST_IP=$(cat $LAST_IP_FILE)
fi

if [[ $LAST_IP != $REQ_IP ]]; then
	cat $ZONEFILE | sed "4s/.*/${TIMESTAMP}/" | sed "s/^${SUBDOMAIN}.*/${SUBDOMAIN} IN A ${REQ_IP}/" > $ZONEFILE
	/etc/rc.d/nsd reload
	echo $REQ_IP > $LAST_IP_FILE
	echo "update"
fi
