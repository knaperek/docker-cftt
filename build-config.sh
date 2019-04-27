#!/bin/dash
set -e

CERT_PATH=/etc/ssl/certs
KEY_PATH=/etc/ssl/keys

# Global config
echo "; Config auto-generated during Docker image build
foreground = yes
log = append
pid = /var/run/stunnel/stunnel.pid
setuid = stunnel
setgid = stunnel
"

is_master=1
for service_key in $KEY_PATH/*.pem;
do
	pem_filename=$( basename $service_key )
	service_name="${pem_filename%.pem}"

	if [ $is_master ];
	then
		echo -n "
[master]
accept = 443"
		is_master=''

	else
		echo -n "
[$service_name]
sni = master:$service_name"
	fi

	# Common config for both the master and the "slave" config sections
	echo "
cert = $CERT_PATH/$pem_filename
key = $service_key
connect = $service_name:80
CAfile = /etc/ssl/certs/origin-pull-ca.pem
verifyChain = yes
TIMEOUTclose = 0
delay=yes"

done