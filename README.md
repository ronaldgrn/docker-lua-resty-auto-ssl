# Docker lua-resty-auto-ssl

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
Generate fallback cert or place your own valid ssl cert in the ssl dir.
```
openssl req -new -newkey rsa:2048 -days 3650 -nodes -x509 \
    -subj '/CN=auto-ssl-fallback' \
    -keyout ssl/resty-auto-ssl-fallback.key \
    -out ssl/resty-auto-ssl-fallback.crt
```

Deploy
```
docker run -it \
    -p 80:80 \
    -p 443:443 \
    --restart always \
    --env DNS_DOMAIN=target.cname.xyz \
    --env PROXY_PASS=http://127.0.0.1:80 \
    ronaldgrn/docker-lua-resty-auto-ssl:0.0.1
```

Update `DNS_DOMAIN` and `PROXY_PASS` as necessary.

`DNS_DOMAIN` - valid cname pointing to the node this is deployed on.

`PROXY_PASS` - address we will be proxying. Ideally should be an internal ip. protocol is required.


=== DEV ===
Say we want to proxy a local Django server, then, in the Django project

```
./manage.py runserver 0.0.0.0:8000
```

In this project
```
docker build -t openresty .
docker run -it --rm \
    -p 80:80 \
    -p 443:443 \
    --env DNS_DOMAIN=nf.syscloak.com \
    --env PROXY_PASS=http://172.17.0.1:8000 \
    openresty
```


## Credits

**[lua-resty-auto-ssl](https://github.com/GUI/lua-resty-auto-ssl)** - library that actually does the OpenResty magic.

**[dehydrated](https://github.com/lukas2511/dehydrated)** - the client used internally that does all the heavy lifting with Let's Encrypt.