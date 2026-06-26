#!/usr/bin/env bash


set -e


VERDE='\033[0;32m'
VERMELHO='\033[0;31m'
AZUL='\033[0;34m'
AMARELO='\033[1;33m'
RESET='\033[0m'

print_logo() {
    clear
    echo -e "${AZUL}"
    cat << "EOF"
         .--.
        |o_o |       ███╗   ██╗██╗   ██╗██████╗ ██╗     ███████╗██╗   ██╗██╗  ██╗
        |:_/ |       ████╗  ██║██║   ██║██╔════╝██║     ██╔════╝██║   ██║╚██╗██╔╝
       //   \ \      ██╔██╗ ██║██║   ██║██║     ██║     █████╗  ██║   ██║ ╚███╔╝ 
      (|     | )     ██║╚██╗██║██║   ██║██║     ██║     ██╔══╝  ██║   ██║ ██╔██╗ 
     /'\_   _/`\     ██║ ╚████║╚██████╔╝╚██████╗███████╗███████╗╚██████╔╝██╔╝ ██╗
     \___)=(___/     ╚═╝  ╚═══╝ ╚═════╝  ╚═════╝╚══════╝╚══════╝ ╚═════╝ ╚═╝  ╚═╝
                                  [ From programmers to programmers]
EOF
    echo -e "${RESET}"
}

msg_info() {
    echo -e "${AZUL}[INFO]${RESET} $1"
}

msg_ok() {
    echo -e "${VERDE}[  OK  ]${RESET} $1"
}

msg_erro() {
    echo -e "${VERMELHO}[ERRO]${RESET} $1"
    exit 1
}

clear
print_logo

if [[ $EUID -eq 0 ]]; then
   msg_erro "Este script NÃO pode ser rodado como root! Execute apenas: ./install.sh"
fi


msg_info "Testando conexão com os servidores do Arch..."
if ! ping -c 1 archlinux.org &> /dev/null; then
    msg_erro "Sem conexão com a internet. Verifique sua rede na VM e tente de novo."
fi
msg_ok "Conexão com a internet confirmada."


if [ -f /var/lib/pacman/db.lck ]; then
    msg_info "Trava do Pacman encontrada. Removendo..."
    sudo rm /var/lib/pacman/db.lck
    msg_ok "Trava removida."
fi

msg_ok "Ambiente verificado com sucesso. Pronto para iniciar a instalação."

msg_info "Verificando se o 'yay' já está instalado..."

if ! command -v yay &> /dev/null; then
    msg_info "O 'yay' não foi encontrado. Iniciando compilação automática..."
    
    cd /tmp
    
    rm -rf yay-bin

    git clone https://aur.archlinux.org/yay-bin.git
    cd yay-bin
    
    makepkg -si --noconfirm
    
    cd - &> /dev/null
    
    msg_ok "Gerenciador 'yay' instalado com sucesso!"
else
    msg_ok "O 'yay' já está instalado no sistema. Pulando etapa."
fi

if [ -f "programas-nucleux.txt" ]; then
    msg_info "Lendo lista de pacotes em 'pkgs-dev.txt'..."
    yay -S --needed --noconfirm $(sed 's/#.*//' "programas-nucleux.txt")
    msg_ok "Todos os pacotes instalados!"
else
    msg_erro "Arquivo 'programas-nucleux.txt' não encontrado!"
fi
