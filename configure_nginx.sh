#!/bin/bash

# 存储 nginx.conf 静态内容的变量
nginx_conf="worker_processes 1;

events {
  worker_connections 1024;
}

http {"

# 循环遍历环境变量并生成 server block
while IFS='=' read -r env_key env_value; do
  if [[ $env_key == SERVER_NAME_* ]]; then
    index="${env_key#SERVER_NAME_}"
    proxy_pass_var="PROXY_PASS_$index"
    proxy_pass_value="${!proxy_pass_var}"

    if [ ! -z "$proxy_pass_value" ]; then
      # 将 server block 追加到 nginx 配置字符串中
      nginx_conf+="
    server {
        listen ${PORT};
        server_name $env_value;

        location / {
            auth_basic \"Restricted\";
            auth_basic_user_file /etc/nginx/.htpasswd;

            proxy_set_header X-Real-IP \$remote_addr;
            proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
            proxy_set_header Host \$http_host;
            proxy_set_header X-Nginx-Proxy true;
            proxy_http_version 1.1;
            proxy_pass $proxy_pass_value;
        }
    }"
    fi
  fi
done < <(env)

# 结束 http {} 块并完成 nginx 配置字符串
nginx_conf+="

}"
echo "Generated nginx.conf:"
echo "$nginx_conf"

# 使用 envsubst 替换 PORT 变量
echo "$nginx_conf" | envsubst '${PORT}' > /etc/nginx/nginx.conf
echo "Generated nginx.conf from environment variables:"
cat /etc/nginx/nginx.conf
