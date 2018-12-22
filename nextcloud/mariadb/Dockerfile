#Original von:
#https://github.com/yobasystems/alpine-mariadb
#Kleinigkeiten angepasst

FROM scratch

LABEL maintainer "Bernhard Hübner <bernhard.huebner@huebner-net.de>" architecture="ARM32v7/armhf"  alpineversion="3.7.0" build="06052018" version="10.1.28"

ADD alpine-minirootfs-3.7.0-armhf.tar.gz /

RUN apk --no-cache add mariadb mariadb-client pwgen

ADD files/run.sh /scripts/run.sh

RUN mkdir /scripts/pre-exec.d && \
    mkdir /scripts/pre-init.d && \
    chmod -R 755 /scripts

EXPOSE 3306

VOLUME ["/var/lib/mysql"]

ENTRYPOINT ["/scripts/run.sh"]

CMD ["/bin/sh"]
