#!/bin/bash
if [[ -z "${DNS_DOMAIN}" ]]; then
  echo "DNS_DOMAIN env is required"
  exit 1
fi

if [[ -z "${PROXY_PASS}" ]]; then
  echo "PROXY_PASS env is required"
  exit 1
fi

if [[ -z "${STORAGE_ADAPTER}" ]]; then
  # Should be one of 'file' or 'redis'
  echo "STORAGE_ADAPTER env not provided. Falling back to file storage."
  STORAGE_ADAPTER="file"
fi

if [[ -z "${RESOLVER}" ]]; then
  # Should be one of 'file' or 'redis'
  echo "RESOLVER env not provided. Defaulting to 8.8.8.8."
  RESOLVER="8.8.8.8"
fi

if [ "${STORAGE_ADAPTER}" == "redis" ]; then
  if [[ -z "${REDIS_HOST}" ]]; then
    echo "REDIS_HOST env is required if using redis storage adapter."
    exit 1
  fi

  if [[ -z "${REDIS_PORT}" ]]; then
    echo "Warn: Using default REDIS_PORT [6379]"
    REDIS_PORT="6379"
  fi
else
  # We need values anyways for the syntax to be valid
  REDIS_HOST="127.0.0.1"
  REDIS_PORT="6379"
fi

# replace with parameter expansion for slashes
sed -i -e "s/{{ DNS_DOMAIN }}/${DNS_DOMAIN//\//\\/}/g" /usr/local/openresty/nginx/conf/nginx.conf
sed -i -e "s/{{ PROXY_PASS }}/${PROXY_PASS//\//\\/}/g" /usr/local/openresty/nginx/conf/nginx.conf
sed -i -e "s/{{ STORAGE_ADAPTER }}/${STORAGE_ADAPTER}/g" /usr/local/openresty/nginx/conf/nginx.conf
sed -i -e "s/{{ RESOLVER }}/${RESOLVER}/g" /usr/local/openresty/nginx/conf/nginx.conf
sed -i -e "s/{{ REDIS_HOST }}/${REDIS_HOST//\//\\/}/g" /usr/local/openresty/nginx/conf/nginx.conf
sed -i -e "s/{{ REDIS_PORT }}/${REDIS_PORT}/g" /usr/local/openresty/nginx/conf/nginx.conf

echo "SETUP OK"
exit 0