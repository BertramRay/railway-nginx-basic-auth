FROM nginx:alpine AS runtime

RUN apk add --no-cache bash

ARG SERVER_NAME=_
ARG PROXY_PASS=http://host.docker.internal:3000
ARG PORT=4000
ARG USERNAME=user
ARG PASSWORD=password

RUN echo "server_name: $SERVER_NAME\nproxy_pass: $PROXY_PASS\nport: $PORT\nusername: $USERNAME\npassword: $PASSWORD"

COPY ./configure_nginx.sh /etc/nginx/configure_nginx.sh
RUN chmod +x /etc/nginx/configure_nginx.sh
RUN /etc/nginx/configure_nginx.sh

ENV USERNAME=$USERNAME
ENV PASSWORD=$PASSWORD
RUN apk add --no-cache openssl
COPY ./gen_passwd.sh /etc/nginx/gen_passwd.sh
RUN ["chmod", "+x", "/etc/nginx/gen_passwd.sh"]
RUN /etc/nginx/gen_passwd.sh
EXPOSE ${PORT}