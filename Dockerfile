FROM alpine:3.17

RUN apk upgrade --no-cache --available

RUN apk add --update --no-cache curl libgcc openssl
RUN curl -o glibc-2.21-r2.apk "https://circle-artifacts.com/gh/andyshinn/alpine-pkg-glibc/6/artifacts/0/home/ubuntu/alpine-pkg-glibc/packages/x86_64/glibc-2.21-r2.apk"
RUN apk add --no-cache --allow-untrusted glibc-2.21-r2.apk
RUN curl -o glibc-bin-2.21-r2.apk "https://circle-artifacts.com/gh/andyshinn/alpine-pkg-glibc/6/artifacts/0/home/ubuntu/alpine-pkg-glibc/packages/x86_64/glibc-bin-2.21-r2.apk"
RUN apk add --no-cache --allow-untrusted glibc-bin-2.21-r2.apk
RUN /usr/glibc/usr/bin/ldconfig /lib /usr/glibc/usr/lib
RUN echo 'hosts: files mdns4_minimal [NOTFOUND=return] dns mdns4' >> /etc/nsswitch.conf

# Install necessary packages & Create sym link for libssl because the CentOS 6 has newer version than what uTorrent requires
RUN ln -s /usr/lib/libssl.so.1.0.0 /usr/lib/libssl.so.0.9.8 && \
    ln -s /usr/lib/libcrypto.so.1.0.0 /usr/lib/libcrypto.so.0.9.8

# usermod & groupmod
RUN apk add --no-cache shadow
RUN adduser -S -D -h /opt/utorrent -s /bin/sh utorrent

# Add user utorrent
RUN useradd --home-dir /opt/utorrent --create-home --shell /bin/bash utorrent

# work dirs
RUN mkdir -p /data
RUN mkdir -p /opt/utorrent/{autoload,conf,settings,torrents,webui}

# Setup utorrent server
RUN curl -SL https://download-hr.utorrent.com/track/beta/endpoint/utserver/os/linux-x64-ubuntu-13-04 --output /tmp/utserver.tar.gz
RUN tar -xf /tmp/utserver.tar.gz -C /tmp
RUN mv /tmp/utorrent-server-alpha-v3_3/docs /opt/utorrent
RUN mv /tmp/utorrent-server-alpha-v3_3/utserver /opt/utorrent
RUN mv /tmp/utorrent-server-alpha-v3_3/webui.zip /opt/utorrent/webui
RUN curl -SL https://github.com/nohnaimer/utorrent-docker/raw/master/utserver.conf --output /opt/utorrent/conf/utserver.conf

# Fix permissions
RUN chown -R utorrent:utorrent /data /opt/utorrent

VOLUME ["/opt/utorrent/settings", "/opt/utorrent/autoload", "/opt/utorrent/torrents", "/data"]
EXPOSE 8080 6881
HEALTHCHECK --interval=30s --timeout=10s --retries=5 CMD curl -sSf http://127.0.0.1:8080/gui

WORKDIR /opt/utorrent

# Setting up the entry point to allow for graceful exit when the container is stopped
ENTRYPOINT ["/opt/utorrent/utserver", "-settingspath", "/opt/utorrent/settings", "-configfile"]
CMD ["/opt/utorrent/conf/utserver.conf", "-logfile", "/dev/stdout", "&"]

# Clean up
RUN apk del curl
RUN rm -rf glibc-2.21-r2.apk glibc-bin-2.21-r2.apk /var/cache/apk/*