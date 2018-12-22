#! /bin/sh

reserved=12582912
availableMemory=$((1024 * $( (fgrep MemAvailable /proc/meminfo || fgrep MemTotal /proc/meminfo) | sed 's/[^0-9]//g' ) ))
if [ $availableMemory -le $(($reserved * 2)) ]; then
    echo "Not enough memory" >&2
    exit 1
fi
availableMemory=$(($availableMemory - $reserved))
msg_cache_size=$(($availableMemory / 3))
rr_cache_size=$(($availableMemory / 3))
nproc=$(nproc)
if [ $nproc -gt 1 ]; then
    threads=$(($nproc - 1))
else
    threads=1
fi

# if the user hasn't mounted their own unbound.conf, use this default:
if [ ! -f /etc/unbound/unbound.conf ]; then
    sed \
        -e "s/@MSG_CACHE_SIZE@/${msg_cache_size}/" \
        -e "s/@RR_CACHE_SIZE@/${rr_cache_size}/" \
        -e "s/@THREADS@/${threads}/" \
        > /etc/unbound/unbound.conf << EOT
server:
    num-threads: @THREADS@
    interface: 0.0.0.0
    interface: ::0
    cache-min-ttl: 60
    do-daemonize: no
    username: "unbound"
    hide-version: yes
    hide-identity: yes
    identity: "DNS"
    harden-algo-downgrade: yes
    do-not-query-localhost: no
    prefetch: yes
    prefetch-key: yes
    ratelimit: 1000
    rrset-roundrobin: yes
    chroot: "/etc/unbound"
    directory: "/etc/unbound"
    auto-trust-anchor-file: "var/root.key"
    num-queries-per-thread: 4096
    outgoing-range: 8192
    msg-cache-size: @MSG_CACHE_SIZE@
    rrset-cache-size: @RR_CACHE_SIZE@
    neg-cache-size: 4M
    serve-expired: yes
    use-caps-for-id: yes
    private-address: 10.0.0.0/8
    private-address: 172.16.0.0/12
    private-address: 192.168.0.0/16
    private-address: 169.254.0.0/16
    private-address: fd00::/8
    private-address: fe80::/10
    private-address: ::ffff:0:0/96
    access-control: 127.0.0.1/32 allow
    access-control: 192.168.0.0/16 allow
    access-control: 172.16.0.0/12 allow
    access-control: 10.0.0.0/8 allow
    include: /etc/unbound/conf.d/*.conf
    tls-cert-bundle: /etc/ssl/certs/ca-certificates.crt
    edns-tcp-keepalive: yes
EOT
fi

mkdir -p /etc/unbound/dev && \
cp -a /dev/random /dev/urandom /etc/unbound/dev/

if [ ! -f /etc/unbound/unbound.log ]; then
	touch /etc/unbound/unbound.log
	chown unbound:unbound /etc/unbound/unbound.log
fi

mkdir -p -m 700 /etc/unbound/var && \
chown unbound:unbound /etc/unbound/var && \
/usr/sbin/unbound-anchor -a /etc/unbound/var/root.key

exec /usr/sbin/unbound -d -c /etc/unbound/unbound.conf
