#!/bin/bash
if [[ -z "${DNS_DOMAIN}" ]]; then
  echo "DNS_DOMAIN env is required"
  exit 1
else
  DNS_DOMAIN="${DNS_DOMAIN}"
fi

if [[ -z "${PROXY_PASS}" ]]; then
  echo "PROXY_PASS env is required"
  exit 1
else
  PROXY_PASS="${PROXY_PASS}"
fi

# replace with parameter expansion for slashes
sed -i -e "s/{{ DNS_DOMAIN }}/${DNS_DOMAIN//\//\\/}/g" /usr/local/openresty/nginx/conf/nginx.conf
sed -i -e "s/{{ PROXY_PASS }}/${PROXY_PASS//\//\\/}/g" /usr/local/openresty/nginx/conf/nginx.conf

echo "SETUP OK"
exit 0