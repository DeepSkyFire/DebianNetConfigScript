#!/bin/bash

ethname=$(cat /proc/net/dev | grep -v lo | awk '{if($2>0 && NR > 2) print substr($1, 0, index($1, ":") - 1)}')

mainip=""
echo "Debian 9+ or ubuntu 16.04+ Network Config"
read -p "Type your Main IP address:" mainip
if [ "$mainip" = "" ]; then
   echo "IP can not be empty!"
   exit 1
fi

netmaskstr=""
read -p "Type your netmask:" netmaskstr
if [ "$netmaskstr" = "" ]; then
   echo "Netmask can not be empty!"
   exit 1
fi

gatewaystr=""
read -p "Type your gateway:" gatewaystr
if [ "$gatewaystr" = "" ]; then
   echo "Gateway can no be empty!"
   exit 1
fi

NETWORK_CONFIGS_FILE="/etc/network/interfaces"

NETWORK_CONFIGS_TEMP_FILE="/tmp/temp_interfaces.txt"

echo "# This file describes the network interfaces available on your system" > $NETWORK_CONFIGS_TEMP_FILE
echo "# and how to activate them. For more information, see interfaces(5)." >> $NETWORK_CONFIGS_TEMP_FILE
echo "" >> $NETWORK_CONFIGS_TEMP_FILE
echo "source /etc/network/interfaces.d/*" >> $NETWORK_CONFIGS_TEMP_FILE
echo "" >> $NETWORK_CONFIGS_TEMP_FILE
echo "# The loopback network interface" >> $NETWORK_CONFIGS_TEMP_FILE
echo "auto lo $ethname" >> $NETWORK_CONFIGS_TEMP_FILE
echo "iface lo inet loopback" >> $NETWORK_CONFIGS_TEMP_FILE
echo "iface $ethname inet static" >> $NETWORK_CONFIGS_TEMP_FILE
echo "       address $mainip" >> $NETWORK_CONFIGS_TEMP_FILE
echo "       netmask $netmaskstr" >> $NETWORK_CONFIGS_TEMP_FILE
echo "       broadcast $mainip" >> $NETWORK_CONFIGS_TEMP_FILE
echo "       post-up route add $gatewaystr dev $ethname" >> $NETWORK_CONFIGS_TEMP_FILE
echo "       post-up route add default gw $gatewaystr" >> $NETWORK_CONFIGS_TEMP_FILE
echo "       pre-down route del $gatewaystr dev $ethname" >> $NETWORK_CONFIGS_TEMP_FILE
echo "       pre-down route del default gw $gatewaystr" >> $NETWORK_CONFIGS_TEMP_FILE

cat $NETWORK_CONFIGS_TEMP_FILE >$NETWORK_CONFIGS_FILE

rm $NETWORK_CONFIGS_TEMP_FILE

echo "nameserver 8.8.8.8" > /etc/resolvconf/resolv.conf.d/base
echo "nameserver 8.8.4.4" >> /etc/resolvconf/resolv.conf.d/base

clear
echo "Done. Please reboot your VPS and switch to Bridge mode on your VM-Master."
echo " "
echo "Nerwork information:"
ifconfig