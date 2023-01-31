FROM myregistry.io:8088/library/mynginx:1.23.2

COPY project/build /usr/share/nginx/html
COPY default.conf /etc/nginx/conf.d/default.conf
