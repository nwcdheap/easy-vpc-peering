#!/bin/bash -xe

SERVER_IP=$1
VPC_CIDR=$2
PSK=$3

yum -y install openvpn

#/usr/sbin/openvpn

mkdir -p /data/openvpn/{etc,bin,sbin}

##
echo "daemon
cd /data/openvpn/etc/
remote ${SERVER_IP} 1200
proto tcp-client
;proto udp
dev tun
ifconfig 10.8.0.2 10.8.0.1
secret static.key
comp-lzo
keepalive 10 60
ping-timer-rem
persist-tun
persist-key
status openvpn-status.log
;verb 5
cipher AES-128-CBC
" > /data/openvpn/etc/client-static.conf

echo "-----BEGIN OpenVPN Static key V1-----
$PSK
-----END OpenVPN Static key V1----- " > /data/openvpn/etc/static.key

##

echo "1 vpn" >> /etc/iproute2/rt_tables
ETH0_IP=`ifconfig eth0 | grep "inet addr" | awk '{print $2}' | cut -d: -f2`

F=/data/openvpn/sbin/startup.sh
echo "#/bin/bash
/usr/sbin/openvpn --config /data/openvpn/etc/client-static.conf

## IP Routing
/sbin/ip rule add from ${VPC_CIDR} table vpn
/sbin/ip rule add from ${ETH0_IP} table main
/sbin/ip route flush cache

echo 1 > /proc/sys/net/ipv4/ip_forward

## IPtables
/sbin/iptables -t nat -A POSTROUTING -o tun+ -j MASQUERADE
/sbin/iptables -t nat -A POSTROUTING -o eth+ -j MASQUERADE

## VPN Monitor
nohup /data/openvpn/sbin/vpn_monitor.sh &

exit 0" > $F
chmod +x $F

F=/data/openvpn/sbin/vpn_monitor.sh
echo "#!/bin/bash

LOG=/var/log/vpn_monitor.log

# 2018/04/28
WHITELIST_SUBNET=\"169.254.169.254/32\"
BJS_SUBNET=\"52.80.0.0/16 52.81.0.0/16 52.94.249.0/28 52.95.255.144/28 54.222.0.0/19 54.222.32.0/22 54.222.36.0/22 54.222.48.0/22 54.222.57.0/24 54.222.58.0/28 54.222.128.0/17 54.223.0.0/16 54.239.0.144/28 54.222.48.0/22 52.80.0.0/16 52.81.0.0/16 52.94.249.0/28 52.95.255.144/28 54.222.32.0/22 54.222.36.0/22 54.222.128.0/17 54.223.0.0/16\"
ZHY_SUBNET=\"52.82.176.0/22 52.82.180.0/22 52.82.187.0/24 52.82.188.0/22 52.82.192.0/18 52.83.0.0/16 52.94.249.16/28 54.239.0.176/28 52.82.188.0/22 52.82.176.0/22 52.82.180.0/22 52.83.0.0/16 52.94.249.16/28\"

GW=`/sbin/ip route | grep default | awk '{print $3}'`

function do_log()
{
    TIME=\`date +\"%Y-%m-%d %T\"\`
    echo \"\$TIME \$1\" >> \$LOG
}

function refresh_to_vpn_route()
{
    /sbin/ip route add default via 10.8.0.1 table vpn
	/sbin/ip route add ${VPC_CIDR} via \$GW table vpn

	for N in \${WHITELIST_SUBNET}; do
		/sbin/ip route add \$N via \$GW table vpn
	done

	for N in \${BJS_SUBNET}; do
		/sbin/ip route add \$N via \$GW table vpn
	done

	for N in \${ZHY_SUBNET}; do
		/sbin/ip route add \$N via \$GW table vpn
	done

    /sbin/ip route fulsh cache
}

while [ 1 ]; do
    CHG=0

    if [ \`/sbin/ip route list table vpn  | grep -c 10.8.0.1\` -eq 0 ]; then
        refresh_to_vpn_route
        do_log "refresh_to_vpn_route"
        CHG=1
    fi


    sleep 60
done

exit 0
" > $F

chmod +x $F

##
echo "/data/openvpn/sbin/startup.sh" >> /etc/rc.local

## First run
#/data/openvpn/sbin/startup.sh



exit 0
