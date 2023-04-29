FROM alpine:3.17

RUN apk upgrade --no-cache --available

RUN apk add --update --no-cache curl openssl openssl-dev

# Create sym link for libssl
RUN ln -s /usr/lib/libssl.so /usr/lib/libssl.so.0.9.8
RUN ln -s /usr/lib/libcrypto.so /usr/lib/libcrypto.so.0.9.8

# Add user utorrent
RUN apk add --no-cache shadow
RUN adduser -S -D -h /opt/utorrent -s /bin/sh utorrent

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
RUN mv /tmp/utorrent-server-alpha-v3_3/utserver /opt/utorrent
RUN mv /tmp/utorrent-server-alpha-v3_3/webui.zip /opt/utorrent/webui
COPY utserver.conf /opt/utorrent/conf/utserver.conf

# Fix permissions
RUN chown -R utorrent: /data /opt/utorrent

VOLUME ["/opt/utorrent/settings", "/opt/utorrent/autoload", "/opt/utorrent/torrents", "/data"]
EXPOSE 8080 6881
HEALTHCHECK --interval=30s --timeout=10s --retries=5 CMD curl -sSf http://127.0.0.1:8080/gui

WORKDIR /opt/utorrent

# Setting up the entry point to allow for graceful exit when the container is stopped
ENTRYPOINT ["/opt/utorrent/utserver", "-settingspath", "/opt/utorrent/settings", "-configfile"]
CMD ["/opt/utorrent/conf/utserver.conf", "-logfile", "/dev/stdout", "&"]

# Clean up
RUN apk del curl
RUN rm -rf /var/cache/apk/*