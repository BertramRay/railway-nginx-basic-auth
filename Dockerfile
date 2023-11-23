FROM nginx:alpine AS runtime

RUN apk add --no-cache bash

ARG PROXY_PASS=http://host.docker.internal:3000
ARG PORT=4000
ARG USERNAME=user
ARG PASSWORD=password
ARG SERVER_NAME_1=nginx-basic-auth-production-1b4a.up.railway.app
ARG PROXY_PASS_1=http://aws-ses-template-manager.railway.internal:3333
ENV SERVER_NAME_1=$SERVER_NAME_1
ENV PROXY_PASS_1=$PROXY_PASS_1

RUN echo "proxy_pass: $PROXY_PASS\nport: $PORT\nusername: $USERNAME\npassword: $PASSWORD"

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