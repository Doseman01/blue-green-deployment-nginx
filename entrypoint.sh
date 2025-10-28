#!/bin/sh

# Render the nginx.conf from the template using environment variables
envsubst '${PORT}' < /etc/nginx/nginx.conf.template > /etc/nginx/nginx.conf

# Start nginx in the foreground
nginx -g 'daemon off;'
