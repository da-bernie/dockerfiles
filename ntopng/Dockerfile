FROM multiarch/debian-debootstrap:armhf-stretch-slim

MAINTAINER Bernhard Huebner <bernhard.huebner@huebner-net.de>

ENV DEBIAN_FRONTEND=noninteractive

# Install dependencies
RUN PRE_DEPS='wget ca-certificates gnupg' && \
    set -x && \
    apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y --no-install-recommends $PRE_DEPS && \
    wget http://packages.ntop.org/apt/ntop.key && \
    apt-key add ntop.key && \
    echo "deb http://apt.ntop.org/stretch_pi armhf/" > /etc/apt/sources.list.d/ntop.list && \
    echo "deb http://apt.ntop.org/stretch_pi all/" >> /etc/apt/sources.list.d/ntop.list && \
    apt-get update && \
    apt-get install -y ntopng nprobe libcap2 net-tools curl libdigest-perl-md5-perl && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* && \
    rm -fr /tmp/* /var/tmp/*

# RUN apt-get -y -q install ntopng redis-server libpcap0.8 libmysqlclient18

EXPOSE 3000/tcp

# Copy configuration files
COPY root /

# Prepare NTOPNG start
RUN chmod 755 /srv/run.sh

# Start NTOPNG
CMD ["/srv/run.sh"]
