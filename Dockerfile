# syntax=docker/dockerfile:1

FROM ghcr.io/linuxserver/baseimage-alpine:3.18

# set version label
ARG BUILD_DATE
ARG VERSION
ARG WIREGUARD_RELEASE
LABEL build_version="Linuxserver.io version:- ${VERSION} Build-date:- ${BUILD_DATE}"
LABEL maintainer="thespad"

RUN \
  echo "**** install dependencies ****" && \
  apk add --no-cache --virtual=build-dependencies \
    build-base \
    elfutils-dev \
    gcc \
    git \
    linux-headers && \
  apk add --no-cache \
    bc \
    gnupg \
    grep \
    iproute2 \
    iptables \
    ip6tables \
    iputils \
    libcap-utils \
    libqrencode \
    net-tools \
    openresolv \
    perl \
    python3 && \
  curl -sSL -o - "https://github.com/coredns/coredns/releases/download/v1.11.1/coredns_1.11.1_linux_amd64.tgz" \
    | tar -C /usr/bin/ -xvzf - && chown root:root /usr/bin/coredns && \
  echo "wireguard" >> /etc/modules && \
  echo "**** install wireguard-tools ****" && \
  if [ -z ${WIREGUARD_RELEASE+x} ]; then \
    WIREGUARD_RELEASE=$(curl -sX GET "https://api.github.com/repos/WireGuard/wireguard-tools/tags" \
    | jq -r .[0].name); \
  fi && \
  cd /app && \
  git clone https://git.zx2c4.com/wireguard-tools && \
  cd wireguard-tools && \
  git checkout "${WIREGUARD_RELEASE}" && \
  sed -i 's|\[\[ $proto == -4 \]\] && cmd sysctl -q net\.ipv4\.conf\.all\.src_valid_mark=1|[[ $proto == -4 ]] \&\& [[ $(sysctl -n net.ipv4.conf.all.src_valid_mark) != 1 ]] \&\& cmd sysctl -q net.ipv4.conf.all.src_valid_mark=1|' src/wg-quick/linux.bash && \
  make -C src -j$(nproc) && \
  make -C src install && \
  echo "**** clean up ****" && \
  apk del --no-network build-dependencies && \
  rm -rf \
    /tmp/*

# add local files
COPY /root /

HEALTHCHECK \
  --interval=30s \
  --timeout=10s \
  --retries=5 \
  --start-period=10s \
  CMD wg-healthcheck -t || exit 1

# ports and volumes
EXPOSE 51820/udp
