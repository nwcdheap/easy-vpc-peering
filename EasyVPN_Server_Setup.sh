#!/bin/bash -xe

PSK=$1
PeerVPNSubnets=$2

yum -y install openvpn

#/usr/sbin/openvpn

mkdir -p /data/openvpn/{etc,sbin}

##
echo "daemon
;mode server
cd /data/openvpn/etc/
dev tun
proto tcp-server
;proto udp
port 1200
secret static.key
ifconfig 10.8.0.1 10.8.0.2
comp-lzo
keepalive 10 60
ping-timer-rem
persist-tun
persist-key
persist-key
persist-tun
status openvpn-status.log
;verb 5
cipher AES-128-CBC
" > /data/openvpn/etc/server-static.conf

echo "-----BEGIN OpenVPN Static key V1-----
$PSK
-----END OpenVPN Static key V1----- " > /data/openvpn/etc/static.key

##
F=/data/openvpn/sbin/startup.sh
echo "#/bin/bash
killall openvpn
/usr/sbin/openvpn --config /data/openvpn/etc/server-static.conf

echo 1 > /proc/sys/net/ipv4/ip_forward

## IPtables
#/sbin/iptables -t nat -A POSTROUTING -o tun+ -j MASQUERADE
#/sbin/iptables -t nat -A POSTROUTING -o eth+ -j MASQUERADE

## VPN Monitor
nohup /data/openvpn/sbin/vpn_monitor.sh &

exit 0" > $F
chmod +x $F

F=/data/openvpn/sbin/vpn_monitor.sh
echo "#!/bin/bash

LOG=/var/log/vpn_monitor.log

# 
VPN_SERVER_SUBNETS=\"${PeerVPNSubnets//,/ }\"

VPN_GW=10.8.0.2

function do_log()
{
    TIME=\`date +\"%Y-%m-%d %T\"\`
    echo \"\$TIME \$1\" >> \$LOG
}

function refresh_to_vpn_route()
{
	for N in \${VPN_SERVER_SUBNETS}; do
		/sbin/ip route add \$N via \${VPN_GW} table main
	done

    /sbin/ip route fulsh cache
}

while [ 1 ]; do
    CHG=0

    if [ \`/sbin/ip route list table main  | grep -c \"via \${VPN_GW}\"\` -eq 0 ]; then
        refresh_to_vpn_route
        do_log \"refresh_to_vpn_route\"
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
