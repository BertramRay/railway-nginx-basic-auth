#!/bin/bash

# 存储 nginx.conf 静态内容的变量
nginx_conf="worker_processes 1;

events {
  worker_connections 1024;
}

http {"

# 获取 SERVER_NAME 和 PROXY_PASS 环境变量
server_names=$SERVER_NAME
proxy_passes=$PROXY_PASS

# 转换为数组
IFS=',' read -ra server_name_array <<< "$server_names"
IFS=',' read -ra proxy_pass_array <<< "$proxy_passes"

# 检查数组长度是否匹配
if [ ${#server_name_array[@]} -ne ${#proxy_pass_array[@]} ]; then
  echo "Error: The number of server names and proxy pass values do not match."
  exit 1
fi

# 循环遍历服务器名称和代理传递值数组并生成 server blocks
for ((i = 0; i < ${#server_name_array[@]}; i++)); do
  # 将 server block 追加到 nginx 配置字符串中
  nginx_conf+="
  server {
      listen ${PORT};
      server_name ${server_name_array[$i]};

      location / {
          auth_basic \"Restricted\";
          auth_basic_user_file /etc/nginx/.htpasswd;

          proxy_set_header X-Real-IP \$remote_addr;
          proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
          proxy_set_header Host \$http_host;
          proxy_set_header X-Nginx-Proxy true;
          proxy_http_version 1.1;
          proxy_pass ${proxy_pass_array[$i]};
      }
  }"
done

# 结束 http {} 块并完成 nginx 配置字符串
nginx_conf+="

}"
echo "Generated nginx.conf:"
echo "$nginx_conf"

# 使用 envsubst 替换 PORT 变量
echo "$nginx_conf" | envsubst '${PORT}' > /etc/nginx/nginx.conf
echo "Generated nginx.conf from environment variables:"
cat /etc/nginx/nginx.conf
