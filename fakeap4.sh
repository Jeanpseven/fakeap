#!/bin/bash

interface=""
ssid=""
channel=""

start() {
    sudo iw dev | awk '$1=="Interface"{print $2}'
    read -p "[*] Escolha a interface para usar: " interface

    read -p "[*] Digite o SSID para o access point: " ssid
    read -p "[*] Digite o canal para o access point: " channel

    sudo systemctl stop NetworkManager
    sudo systemctl disable NetworkManager

    sudo airmon-ng check kill
    sleep 5

    sudo airmon-ng start $interface $channel

    sudo service apache2 start

    sudo cp -r sites/* /var/www/html/

    sudo iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
    sudo iptables -A FORWARD -i $interface -o eth0 -j ACCEPT
    sudo sysctl -w net.ipv4.ip_forward=1

    sudo ifconfig $interface up 10.0.0.1 netmask 255.255.255.0
    sudo systemctl start dnsmasq

    sudo service apache2 restart
}

stop() {
    sudo service apache2 stop
    sudo systemctl stop dnsmasq
    sudo iptables -D POSTROUTING -t nat -o eth0 -j MASQUERADE
    sudo iptables -D FORWARD -i $interface -o eth0 -j ACCEPT
    sudo sysctl -w net.ipv4.ip_forward=0
    sudo ifconfig $interface down
    sudo airmon-ng stop $interface
    sudo systemctl start NetworkManager
}

case "$1" in
    --start)
        start
        ;;
    --stop)
        stop
        ;;
    *)
        echo "Uso: $0 {--start|--stop}"
        exit 1
        ;;
esac
