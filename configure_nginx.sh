#!/bin/bash

# Define the placeholder tag for the server blocks in nginx configuration template
SERVER_BLOCKS_PLACEHOLDER="# SERVER_BLOCKS_PLACEHOLDER"

# Define a variable to hold the generated server blocks
server_blocks=""

# Loop through all environment variables
while read -r line; do
  # Extract the key and value of the environment variable
  env_key=$(echo $line | cut -d '=' -f 1)
  env_value=$(echo $line | cut -d '=' -f 2)

  # Check if the environment variable matches the pattern server_name_xxx
  if [[ $env_key == SERVER_NAME_* ]]; then
    # Extract the index xxx
    index=${env_key#SERVER_NAME_}

    # Check if the corresponding proxy_pass_xxx environment variable exists
    proxy_pass_var="PROXY_PASS_$index"
    proxy_pass_value=$(printenv $proxy_pass_var)

    # If it exists, build a new server block
    if [ ! -z "$proxy_pass_value" ]; then
      server_block="\
    server {\n\
        listen ${PORT};\n\
        server_name $env_value;\n\n\
        location / {\n\
            auth_basic \"Restricted\";\n\
            auth_basic_user_file /etc/nginx/.htpasswd;\n\n\
            proxy_set_header X-Real-IP \$remote_addr;\n\
            proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;\n\
            proxy_set_header Host \$http_host;\n\
            proxy_set_header X-Nginx-Proxy true;\n\
            proxy_http_version 1.1;\n\
            proxy_pass $proxy_pass_value;\n\
        }\n\
    }\n"

      # Append the new server block to the server blocks string
      server_blocks+="$server_block\n"
    fi
  fi
done < <(env)

# Replace the SERVER_BLOCKS_PLACEHOLDER in nginx configuration template with the generated server blocks
sed -i "s#${SERVER_BLOCKS_PLACEHOLDER}#${server_blocks}#g" /etc/nginx/nginx.conf.template

# Use envsubst to replace the remaining environment variables
envsubst '$PORT' < /etc/nginx/nginx.conf.template > /etc/nginx/nginx.conf
