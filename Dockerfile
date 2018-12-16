FROM golang:1.11.2

RUN \
  apt-get -yqq update && \
  apt-get -yqq install  \
  build-essential \
  curl \
  dnsutils \
  libpcre3 \
  libpcre3-dev \
  libssl-dev \
  unzip \
  vim \
  zlib1g-dev

RUN \
  cd /tmp && \
  curl -sLo nginx.tgz https://nginx.org/download/nginx-1.15.7.tar.gz && \
  tar -xzvf nginx.tgz

RUN \
  cd /tmp && \
  curl -sLo ndk.tgz https://github.com/simpl/ngx_devel_kit/archive/v0.3.0.tar.gz && \
  tar -xzvf ndk.tgz

RUN \
  mkdir -p /usr/local/nginx/ext && \
  mkdir -p /go/src/github.com/hashicorp && \
  cd /go/src/github.com/hashicorp && \
  git clone https://github.com/hashicorp/ngx_http_consul_backend_module.git && \
  cd ./ngx_http_consul_backend_module && \
  CGO_CFLAGS="-I /tmp/ngx_devel_kit-0.3.0/src" \
  go build \
    -buildmode=c-shared \
    -o /usr/local/nginx/ext/ngx_http_consul_backend_module.so \
    ./src/ngx_http_consul_backend_module.go

RUN \
  cd /tmp/nginx-* && \
  CFLAGS="-g -O0" \
  ./configure \
    --with-debug \
    --add-module=/tmp/ngx_devel_kit-0.3.0 \
    --add-module=/go/src/github.com/hashicorp/ngx_http_consul_backend_module \
    && \
  make && \
  make install

COPY nginx.conf /usr/local/nginx/conf/nginx.conf
EXPOSE 80

STOPSIGNAL SIGTERM

ENTRYPOINT /usr/local/nginx/sbin/nginx
