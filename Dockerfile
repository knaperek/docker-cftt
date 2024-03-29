FROM debian:bullseye-slim

ARG ORIGIN_PULL_CA_SOURCE=https://developers.cloudflare.com/ssl/static/authenticated_origin_pull_ca.pem

RUN apt-get update \
	&& apt-get install -y --no-install-recommends \
	   stunnel4 \
	&& rm -rf /var/lib/apt/lists/*

ADD $ORIGIN_PULL_CA_SOURCE /etc/ssl/certs/origin-pull-ca.pem

COPY build-config.sh /usr/local/bin/

ONBUILD COPY certs/ /etc/ssl/certs/
ONBUILD COPY keys/ /etc/ssl/keys/
ONBUILD RUN chmod 600 /etc/ssl/keys/*
ONBUILD RUN /usr/local/bin/build-config.sh > /etc/stunnel/stunnel.conf

EXPOSE 443

CMD /usr/bin/stunnel /etc/stunnel/stunnel.conf
