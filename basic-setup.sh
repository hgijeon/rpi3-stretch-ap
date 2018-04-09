#!/bin/bash
#
# This version uses Raspbian March 2018 stretch image, please use this image
#

if [ "$EUID" -ne 0 ]
    then echo "Must be root"
    exit
fi

if [[ $# -lt 2 ]]; 
    then echo "You need to pass a password and name!"
    echo "Usage:"
    echo "sudo $0 [apPassword] [apName]"
    exit
fi

APPASS="$1"
APSSID="$2"

if [[ $# -eq 2 ]]; then
    APSSID=$2
fi

apt-get remove --purge hostapd -yqq
echo "apt update"
apt-get update -yqq
echo "apt upgrade"
apt-get upgrade -yqq
echo "apt update again to refresh"
apt-get update -yqq
echo "installing packages"
apt-get install hostapd dnsmasq -yqq

cat > /etc/dnsmasq.conf <<EOF
interface=wlan0
dhcp-range=10.0.0.2,10.0.0.50,255.255.255.0,12h
EOF

cat > /etc/hostapd/hostapd.conf <<EOF
interface=wlan0
hw_mode=g
channel=10
auth_algs=1
wpa=2
wpa_key_mgmt=WPA-PSK
wpa_pairwise=CCMP
rsn_pairwise=CCMP
wpa_passphrase=$APPASS
ssid=$APSSID
ieee80211n=1
wmm_enabled=1
ht_capab=[HT40][SHORT-GI-20][DSSS_CCK-40]
EOF

sed -i -- 's/allow-hotplug wlan0//g' /etc/network/interfaces
sed -i -- 's/iface wlan0 inet manual//g' /etc/network/interfaces
sed -i -- 's/    wpa-conf \/etc\/wpa_supplicant\/wpa_supplicant.conf//g' /etc/network/interfaces
sed -i -- 's/#DAEMON_CONF=""/DAEMON_CONF="\/etc\/hostapd\/hostapd.conf"/g' /etc/default/hostapd

cat >> /etc/network/interfaces <<EOF
# Added by rPi Access Point Setup
allow-hotplug wlan0
iface wlan0 inet static
    address 10.0.0.1
    netmask 255.255.255.0
    network 10.0.0.0
    broadcast 10.0.0.255

# if eth0 needs dhcp
auto eth0
    allow-hotplug eth0
    iface eth0 inet dhcp

EOF

echo "denyinterfaces wlan0" >> /etc/dhcpcd.conf

systemctl enable hostapd
systemctl enable dnsmasq

sudo service hostapd start
sudo service dnsmasq start

echo "All done! Please reboot"
