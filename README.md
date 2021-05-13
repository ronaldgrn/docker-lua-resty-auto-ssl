# docker lua-resty-auto-ssl

Docker wrapper around the reliable **[lua-resty-auto-ssl](https://github.com/GUI/lua-resty-auto-ssl)** library with multi-tenant and redis support.

**Notes:**

This image expects there is a single CNAME that all 'approved' domains should be pointing to before attempting ssl cert generation.

All requests to http will be redirected to https.

Uses the sample dns query config from **[lua-resty-dns](https://github.com/openresty/lua-resty-dns)**. Feel free to adjust the values to suit your needs as as neessary.

By default exposes /debug-dns for quick debugging. This can be used as a healthcheck or optionally moved/removed in production. Sample result:

```
current host:  nf.syscloak.com
target cname:  nf.syscloak.com
dns records:
  nf.syscloak.com 127.0.0.1 type:1 class:1 ttl:299
generate ssl?: false
```


## Deploy Instructions

Deploy with redis storage
```
docker run -it \
    -p 80:80 \
    -p 443:443 \
    --restart always \
    --env DNS_DOMAIN=target.cname.xyz \
    --env PROXY_PASS=http://127.0.0.1:80 \
    --env STORAGE_ADAPTER=redis \
    --env REDIS_HOST=127.0.0.1 \
    --env REDIS_PORT=6379 \
    ronaldgrn/docker-lua-resty-auto-ssl:1.0.0
```

Deploy with file storage (not recommended)
```
docker run -it \
    -p 80:80 \
    -p 443:443 \
    --restart always \
    --env DNS_DOMAIN=target.cname.xyz \
    --env PROXY_PASS=http://127.0.0.1:80 \
    ronaldgrn/docker-lua-resty-auto-ssl:1.0.0
```

**Protip**: All builds from dockerhub will inevitably have a pre-configured fallback ssl certificate. This is required to start nginx. It is strongly recommended to mount your own certs in production.

eg. To generate and mount a unique cert on your docker machine.
```
mkdir /etc/ssl
```
```
openssl req -new -newkey rsa:2048 -days 3650 -nodes -x509 \
    -subj '/CN=auto-ssl-fallback' \
    -keyout /etc/ssl/resty-auto-ssl-fallback.key \
    -out /etc/ssl/resty-auto-ssl-fallback.crt
```
```
docker run -it \
    -p 80:80 \
    -p 443:443 \
    --restart always \
    --env DNS_DOMAIN=target.cname.xyz \
    --env PROXY_PASS=http://127.0.0.1:80 \
    --env STORAGE_ADAPTER=redis \
    --env REDIS_HOST=127.0.0.1 \
    --env REDIS_PORT=6379 \
    --mount type=bind,source=/etc/ssl/resty-auto-ssl-fallback.key,target=/etc/ssl/resty-auto-ssl-fallback.key,readonly \
    --mount type=bind,source=/etc/ssl/resty-auto-ssl-fallback.crt,target=/etc/ssl/resty-auto-ssl-fallback.crt,readonly \
    ronaldgrn/docker-lua-resty-auto-ssl:1.0.0
```

## Environment Variables

`DNS_DOMAIN` - Valid cname pointing to the node this is deployed on.

`PROXY_PASS` - Address we will be proxying. Ideally should be an internal ip. protocol is required.

`STORAGE_ADAPTER` - One of `redis` or `file`. Defaults to `file`.

`REDIS_HOST` - If using the redis adapter; the redis hostname or ip.

`REDIS_PORT` - If using the redis adapter; the redis port. Defaults to 6379

`RESOLVER` - Nginx resolver. Useful for cases where we need to connect by hostname to a local redis server. Defaults to 8.8.8.8


## Advanced
Say we want to proxy a local Django server, then, in the Django project

```
./manage.py runserver 0.0.0.0:8000
```

In this project, generate a fallback cert or place your own valid ssl cert in the ssl dir.
```
openssl req -new -newkey rsa:2048 -days 3650 -nodes -x509 \
    -subj '/CN=auto-ssl-fallback' \
    -keyout ssl/resty-auto-ssl-fallback.key \
    -out ssl/resty-auto-ssl-fallback.crt
```

then build and run.
```
docker build -t openresty-ssl .
docker run -it --rm \
    -p 80:80 \
    -p 443:443 \
    --env DNS_DOMAIN=nf.syscloak.com \
    --env PROXY_PASS=http://172.17.0.1:8000 \
    openresty-ssl
```


## Credits

**[lua-resty-auto-ssl](https://github.com/GUI/lua-resty-auto-ssl)** - library that actually does the OpenResty magic.

**[dehydrated](https://github.com/lukas2511/dehydrated)** - the client used internally that does all the heavy lifting with Let's Encrypt.