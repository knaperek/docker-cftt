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
	pem_filename=$( basename "$service_key" )
	service_name_with_port="${pem_filename%.pem}"
	service_name="${service_name_with_port%@*}"
	port_part="${service_name_with_port#${service_name}}"
	origin_port=${port_part#@}
	origin_port=${origin_port:-80}

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
connect = $service_name:$origin_port
CAfile = /etc/ssl/certs/origin-pull-ca.pem
verifyChain = yes
TIMEOUTclose = 0
delay=yes"

done
