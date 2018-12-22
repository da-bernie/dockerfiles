FROM scratch

#wget http://dl-cdn.alpinelinux.org/alpine/edge/releases/armhf/alpine-minirootfs-3.8.0-armhf.tar.gz
# mv alpine-minirootfs-3.8.0-armhf.tar.gz rootfs.tar.gz
ADD rootfs.tar.gz /

RUN sed -i -e 's/v[[:digit:]]\.[[:digit:]]/edge/g' /etc/apk/repositories && \
    apk upgrade --no-cache --available && \
    apk add --no-cache unbound=1.8.1-r1 curl bind-tools ca-certificates

COPY unbound.sh /

RUN chmod +x /unbound.sh && \
    mv /etc/unbound/unbound.conf /etc/unbound/unbound.conf.alpine && \
    rm /etc/unbound/root.hints && \
    curl -o /etc/unbound/root.hints https://www.internic.net/domain/named.cache

EXPOSE 53

CMD ["/unbound.sh"]
