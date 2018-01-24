FROM alpine:3.7

MAINTAINER Alxera <admin@alxera.com.cn>

ENV TENGINE_VERSION 2.2.1

RUN \
        apk add --update tzdata && \
        cp -r -f /usr/share/zoneinfo/Asia/Shanghai  /etc/localtime && \
        apk del tzdata

ENV CONFIG "  \
        --user=nginx \
        --group=nginx \
        --with-file-aio \
        --with-pcre \
        --with-ipv6 \
        --with-http_upstream_check_module \
        --add-module=deps/lua-nginx-module \
        --add-module=deps/ngx_devel_kit-0.3.0 \
        --with-http_v2_module \
        --with-http_realip_module \
        --with-http_addition_module \
        --with-http_sub_module \
        --with-http_dav_module \
        --with-http_flv_module \
        --with-http_slice_module \
        --with-http_mp4_module \
        --with-http_gunzip_module \
        --with-http_gzip_static_module \
        --with-http_auth_request_module \
        --with-http_concat_module \
        --with-http_random_index_module \
        --with-http_secure_link_module \
        --with-http_degradation_module \
        --with-http_sysguard_module \
        --with-http_dyups_module \
        --with-mail \
        --with-mail_ssl_module \
        --with-jemalloc \
        --with-http_ssl_module \
        --with-http_stub_status_module \
        --with-http_xslt_module=shared \
        --with-http_image_filter_module=shared \
        --with-http_geoip_module=shared \
        --with-threads \
        " 
        

ADD nginx.h /
#ADD repositories /etc/apk/repositories

WORKDIR /usr/local/nginx

RUN \
    addgroup -S nginx \
    && adduser -D -S -h /usr/local/nginx -s /sbin/nologin -G nginx nginx \
    && apk add --no-cache --virtual .build-deps \
        gcc \
        libc-dev \
        make \
        openssl-dev \
        pcre-dev \
        zlib-dev \
        linux-headers \
        curl \
        jemalloc-dev \
        libxslt-dev \
        luajit-dev \
        gd-dev \
        geoip-dev \
        lua5.1-dev \
    && curl "http://tengine.taobao.org/download/tengine-$TENGINE_VERSION.tar.gz" -o tengine.tar.gz \
    && curl "https://codeload.github.com/simpl/ngx_devel_kit/tar.gz/v0.3.0" -o ngx_devel_kit-v0.3.0.tar.gz \  
    && curl "https://codeload.github.com/openresty/lua-nginx-module/tar.gz/v0.10.11" -o lua-nginx-module-v0.10.11.tar.gz \   
    && mkdir -p /usr/src \
    && tar  -zxC /usr/src -f tengine.tar.gz \
    && mkdir -p /usr/src/tengine-$TENGINE_VERSION/deps \
    && tar -zxC /usr/src/tengine-$TENGINE_VERSION/deps -f ngx_devel_kit-v0.3.0.tar.gz \
    && tar -zxC /usr/src/tengine-$TENGINE_VERSION/deps -f lua-nginx-module-v0.10.11.tar.gz \
    && mv /usr/src/tengine-$TENGINE_VERSION/deps/lua-nginx-module-0.10.11 /usr/src/tengine-$TENGINE_VERSION/deps/lua-nginx-module \
    && rm tengine.tar.gz \
    && rm ngx_devel_kit-v0.3.0.tar.gz \
    && rm lua-nginx-module-v0.10.11.tar.gz \
    && cd /usr/src/tengine-$TENGINE_VERSION/src/core/ \
    && rm nginx.h \
    && mv /nginx.h ./nginx.h \
#    && mv /ngx_user.patch ./ngx_user.patch \
#    && patch ngx_user.c ngx_user.patch \
#    && rm ngx_user.patch \
    && cd ../../../ \
    && cd /usr/src/tengine-$TENGINE_VERSION \
    && ./configure $CONFIG --with-debug \
    && make \
    && mv objs/nginx objs/nginx-debug \
    && ./configure $CONFIG \
    && make \
    && make install \
    && install -m755 objs/nginx-debug /usr/local/nginx/sbin/nginx-debug \
    && strip /usr/local/nginx/sbin/nginx* \
    && runDeps="$( \
        scanelf --needed --nobanner /usr/local/nginx/sbin/nginx /etc/nginx/modules/*.so /tmp/envsubst  \
            | awk '{ gsub(/,/, "\nso:", $2); print "so:" $2 }' \
            | sort -u \
            | xargs -r apk info --installed \
            | sort -u \
    )" \
    && apk add --virtual .nginx-rundeps $runDeps \
    && apk del .build-deps \
    && rm -rf /usr/src/tengine-$TENGINE_VERSION \
    # forward request and error logs to docker log collector
    && ln -sf /dev/stdout /usr/local/nginx/logs/access.log \
    && ln -sf /dev/stderr /usr/local/nginx/logs/error.log

COPY nginx.conf /usr/local/nginx/conf/nginx.conf
COPY nginx.vh.default.conf /usr/local/nginx/conf/conf.d/default.conf

EXPOSE 80 443

CMD ["/usr/local/nginx/sbin/nginx", "-g", "daemon off;"]
