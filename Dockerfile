FROM alpine:3.17

RUN apk upgrade --no-cache --available

RUN apk add --update --no-cache curl libgcc openssl openssl-dev
RUN wget -q -O /etc/apk/keys/sgerrand.rsa.pub https://alpine-pkgs.sgerrand.com/sgerrand.rsa.pub
RUN wget https://github.com/sgerrand/alpine-pkg-glibc/releases/download/2.35-r1/glibc-2.35-r1.apk
RUN wget https://github.com/sgerrand/alpine-pkg-glibc/releases/download/2.35-r1/glibc-bin-2.35-r1.apk
RUN wget https://github.com/sgerrand/alpine-pkg-glibc/releases/download/2.35-r1/glibc-dev-2.35-r1.apk
RUN wget https://github.com/sgerrand/alpine-pkg-glibc/releases/download/2.35-r1/glibc-i18n-2.35-r1.apk
RUN apk add --update --no-cache glibc-2.35-r1.apk glibc-bin-2.35-r1.apk glibc-dev-2.35-r1.apk glibc-i18n-2.35-r1.apk
RUN rm -rf glibc-2.35-r1.apk glibc-bin-2.35-r1.apk glibc-dev-2.35-r1.apk glibc-i18n-2.35-r1.apk

# Create sym link for libssl
#RUN ln -s /usr/lib/libssl.so /usr/lib/libssl.so.0.9.8
#RUN ln -s /usr/lib/libcrypto.so /usr/lib/libcrypto.so.0.9.8
#RUN ln -s /usr/lib/libssl.so.1.0.0 /usr/lib/libssl.so.0.9.8
#RUN ln -s /usr/lib/libcrypto.so.1.0.0 /usr/lib/libcrypto.so.0.9.8
COPY libssl.so.1.0.0 /usr/glibc-compat/lib/
COPY libcrypto.so.1.0.0 /usr/glibc-compat/lib/

# Add user utorrent
RUN apk add --no-cache shadow
RUN adduser -S -D -h /opt/utorrent -s /bin/sh utorrent

# Symbol link
RUN ln -s /lib /lib64

# work dirs
RUN mkdir -p /data
RUN mkdir -p /opt/utorrent/autoload
RUN mkdir -p /opt/utorrent/conf
RUN mkdir -p /opt/utorrent/settings
RUN mkdir -p /opt/utorrent/torrents
RUN mkdir -p /opt/utorrent/webui

# Setup utorrent server
RUN curl -SL https://download-hr.utorrent.com/track/beta/endpoint/utserver/os/linux-x64-ubuntu-13-04 --output /tmp/utserver.tar.gz
RUN tar -xf /tmp/utserver.tar.gz -C /tmp
RUN mv /tmp/utorrent-server-alpha-v3_3/docs /opt/utorrent
RUN mv /tmp/utorrent-server-alpha-v3_3/utserver /opt/utorrent/utorrent
RUN mv /tmp/utorrent-server-alpha-v3_3/webui.zip /opt/utorrent/webui
COPY utserver.conf /opt/utorrent/conf/utserver.conf

# Fix permissions
RUN chown -R utorrent: /data /opt/utorrent

VOLUME ["/opt/utorrent/settings", "/opt/utorrent/autoload", "/opt/utorrent/torrents", "/data"]
EXPOSE 8080 6881
HEALTHCHECK --interval=30s --timeout=10s --retries=5 CMD curl -sSf http://127.0.0.1:8080/gui

WORKDIR /opt/utorrent

# Setting up the entry point to allow for graceful exit when the container is stopped
ENTRYPOINT ["/opt/utorrent/utorrent", "-settingspath", "/opt/utorrent/settings", "-configfile"]
CMD ["/opt/utorrent/conf/utserver.conf", "-logfile", "/dev/stdout", "&"]

# Clean up
RUN apk del curl
RUN rm -rf /var/cache/apk/*