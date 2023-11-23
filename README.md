# Basic Auth Nginx Reverse Proxy for Railway.app's Services

This is for web applications running in railway.app which need a basic auth without modifing source code.
![image](https://github.com/BertramRay/railway-nginx-basic-auth/assets/42647595/5c3c12de-9615-45a4-a7b8-651425f8353a)


You can add to railway easily by this button.

[![Deploy on Railway](https://railway.app/button.svg)](https://railway.app/template/zx4xv3?referralCode=GLhtH9)

## Usage

### Step 1

Fork this repo, and deploy it in the same project which the services you want to add basic auth.

### Step 2

Modify deployed service's enviroment variable. You should know that private network in railway is based on IPV6. So make sure your upstream applications have listened on an IPV6 port.

`ENABLE_ALPINE_PRIVATE_NETWORKING`

Most important one. You need this for alpine image's network.
Just set it to `ENABLE_ALPINE_PRIVATE_NETWORKING=true`.

`PROXY_PASS`

The service's private network you want to be proxied. Now supports multiple values separated by commas.

Example: `http://app-name.up.railway.app:3000,http://another-app-name.up.railway.app:3000`

`SERVER_NAME`

The server name you want to use. Now supports multiple values separated by commas.

Example: `server1.yourdomain.com,server2.yourdomain.com`

`PORT`

The port expose to public. Default is `80`.
But someone said it's necessary for `Railway.app` detecting which port for nging.

`USERNAME`

Username for auth. Default is `user`.

`PASSWORD`

Password for auth. Default is `password`.

## References

1. [Simple HTML App with NGNIX Docker container doesn't run on Railway.app - Application failed to respond (error-503)](https://stackoverflow.com/questions/76348107/simple-html-app-with-ngnix-docker-container-doesnt-run-on-railway-app-applica)
1. [OpenSSL コマンドでサーバー上で直接 .htpasswd に ID & パスワードを追加する](https://qiita.com/katzueno/items/07c8fb54b32e919128d4)
1. [Workaround for Alpine-based images](https://docs.railway.app/reference/private-networking#workaround-for-alpine-based-images)
