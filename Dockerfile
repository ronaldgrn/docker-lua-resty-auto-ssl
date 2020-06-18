FROM openresty/openresty:1.15.8.3-2-bionic

RUN mkdir /etc/resty-auto-ssl
RUN chown www-data /etc/resty-auto-ssl

RUN /usr/local/openresty/luajit/bin/luarocks install lua-resty-auto-ssl

COPY nginx.conf /usr/local/openresty/nginx/conf/nginx.conf
COPY ssl/resty-auto-ssl-fallback.key /etc/ssl/resty-auto-ssl-fallback.key
COPY ssl/resty-auto-ssl-fallback.crt /etc/ssl/resty-auto-ssl-fallback.crt

RUN mkdir /startup
COPY setup.sh /startup/setup.sh

EXPOSE 80/tcp
EXPOSE 443/tcp

# CMD ["/bin/bash", "/startup/setup.sh", "&&", "/usr/local/openresty/bin/openresty", "-g", "'daemon off;'"]
CMD /bin/bash /startup/setup.sh && /usr/local/openresty/bin/openresty -g 'daemon off;'
