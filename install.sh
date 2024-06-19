#!/bin/bash

# Função para exibir mensagens de status
function status_message {
    echo -e "\n\e[1;32m$1\e[0m\n"
}

# Atualizar a lista de pacotes
status_message "Atualizando a lista de pacotes..."
sudo apt update

# Instalar hostapd
status_message "Instalando hostapd..."
sudo apt install -y hostapd

# Instalar isc-dhcp-server (comumente chamado de dhcpd)
status_message "Instalando isc-dhcp-server..."
sudo apt install -y isc-dhcp-server

# Instalar bettercap
status_message "Instalando bettercap..."
sudo apt install -y bettercap

# Instalar lighttpd
status_message "Instalando lighttpd..."
sudo apt install -y lighttpd

status_message "Instalação concluída!"
