FROM openresty/openresty:stretch
COPY ./nginx.conf /usr/local/openresty/nginx/conf/nginx.conf
