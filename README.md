Generate fallback keys
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

Update `DNS_DOMAIN` and `PROXY_PASS` as necessary


=== DEBUG ===

To debug nginx
```
docker run -it --rm \
    -p 80:80 \
    -p 443:443 \
    --mount type=bind,source="$(pwd)"/nginx.conf,target=/usr/local/openresty/nginx/conf/nginx.conf,readonly \
    openresty bash
```

To debug dns i.e (view. cname record) goto `sub.domain.com/debug-dns`
