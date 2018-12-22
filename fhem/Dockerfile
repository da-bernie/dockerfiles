FROM multiarch/debian-debootstrap:armhf-stretch-slim

MAINTAINER Bernhard Huebner <bernhard.huebner@huebner-net.de>

ENV DEBIAN_FRONTEND=noninteractive

# Install dependencies
RUN PRE_DEPS='supervisor gnupg ca-certificates' && \
    set -x && \
    apt-get update && apt-get install -y --no-install-recommends $PRE_DEPS && \
    rm -rf /var/lib/apt/lists/* && \
    rm -fr /tmp/* /var/tmp/*

# Install fhem
RUN wget http://debian.fhem.de/archive.key && \
    apt-key add archive.key && \
    rm archive.key && \
    touch /sbin/init && \
    echo "deb http://debian.fhem.de/nightly/ /" > /etc/apt/sources.list.d/fhem.list && \
    apt-get update && \
    apt-get install -y fhem usbutils && \
    rm -rf /var/lib/apt/lists/* && \
    rm -fr /tmp/* /var/tmp/*

# supervisord.conf for supervisor
RUN mkdir -p /var/log/supervisor
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf
RUN chown fhem /opt/fhem/fhem.cfg

# Ports
EXPOSE 8083

CMD ["/usr/bin/supervisord"]
