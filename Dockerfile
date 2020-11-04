# (c) Copyright 2019-2020, James Stevens ... see LICENSE for details
# Alternative license arrangements are possible, contact me for more information

FROM alpine

RUN rmdir /tmp
RUN ln -s /dev/shm /tmp
RUN ln -s /dev/shm /ram

RUN apk add nginx
RUN apk add gettext

RUN rmdir /var/lib/nginx/tmp /var/log/nginx 
RUN ln -s /dev/shm /var/lib/nginx/tmp
RUN ln -s /dev/shm /var/log/nginx
RUN ln -s /dev/shm /run/nginx

RUN mkdir -p /opt /opt/htdocs
COPY htdocs/index.html /opt/htdocs/index.html

COPY container/inittab /etc/inittab
COPY container/start /opt/start

COPY container/certkey.pem /etc/nginx/
COPY container/pdns-webui.tmpl /etc/nginx/pdns-webui.tmpl
COPY container/htpasswd /etc/nginx/htpasswd

RUN ln -s /ram/pdns-webui.conf /etc/nginx/pdns-webui.conf

CMD [ "/sbin/init" ]
