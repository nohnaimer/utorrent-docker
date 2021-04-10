FROM centos:latest

ENV LC_ALL en_US.UTF-8
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en

RUN dnf update -yqq
RUN dnf install curl glibc-langpack-en -yqq

# Openssl libs
RUN curl -SL https://github.com/nohnaimer/utorrent-docker/raw/master/libcrypto.so.1.0.0 --output  /usr/lib64/libcrypto.so.1.0.0
RUN curl -SL https://github.com/nohnaimer/utorrent-docker/raw/master/libssl.so.1.0.0 --output  /usr/lib64/libssl.so.1.0.0

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

CMD ["/opt/utorrent/utserver", "-settingspath", "/opt/utorrent/settings", "-configfile", "/opt/utorrent/conf/utserver.conf", "-logfile", "/dev/stdout"]

# Clean up
RUN dnf clean all
RUN rm -rf /tmp/ut*