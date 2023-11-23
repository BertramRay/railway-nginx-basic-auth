#!/bin/bash

# Variable to store the static content of nginx.conf
nginx_conf="worker_processes 1;

events {
  worker_connections 1024;
}

http {
    # Increase the bucket size for server names hash tables
    server_names_hash_bucket_size 128;
"

# Split SERVER_NAME and PROXY_PASS into arrays
IFS=',' read -ra server_name_array <<< "${SERVER_NAME}"
IFS=',' read -ra proxy_pass_array <<< "${PROXY_PASS}"

# Check if the lengths of the arrays match
if [ ${#server_name_array[@]} -ne ${#proxy_pass_array[@]} ]; then
  echo "Error: The number of server names and proxy pass values do not match."
  exit 1
fi

# Iterate over the server name and proxy pass value arrays to generate server blocks
for ((i = 0; i < ${#server_name_array[@]}; i++)); do
  # Append the server block to the nginx configuration string
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

# End the http {} block and complete the nginx configuration string
nginx_conf+="

}"
echo "Generated nginx.conf:"
echo "$nginx_conf"
echo "$nginx_conf" > /etc/nginx/nginx.conf
