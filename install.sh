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
    msg_erro "Sem conexão com a internet. Verifique sua rede e tente de novo."
fi
msg_ok "Conexão com a internet confirmada."


if [ -f /var/lib/pacman/db.lck ]; then
    msg_info "Trava do Pacman encontrada. Removendo..."
    sudo rm /var/lib/pacman/db.lck
    msg_ok "Trava removida."
fi

msg_ok "Ambiente verificado com sucesso. Pronto para iniciar a instalação."

msg_info "Verificando se o 'yay' já está instalado..."
sudo pacman -S --needed base-devel git --noconfirm

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
    msg_ok "O 'yay' já está instalado no sistema. prosseguindo com a etapa."
fi

if [ -f "programas-nucleux.txt" ]; then
    msg_info "Lendo lista de programas/pacotes iniciais"
    yay -S --needed --noconfirm $(sed 's/#.*//' "programas-nucleux.txt")
    msg_ok "Todos os pacotes instalados!"
else
    msg_erro "Pasta de programs não encontrado!"
fi

if [ -f "hyprland.txt" ]; then
    msg_info "Instalando Hyprland e dependências estruturais..."
    

    yay -S --needed --noconfirm $(sed 's/#.*//' "hyprland.txt")
    
    msg_ok "Hyprland instalado com sucesso!"
    msg_info "Ativando o gerenciador de login (SDDM)..."
    sudo systemctl enable sddm
else

    msg_error "O arquivo hyprland.txt não foi encontrado!"
fi

if grep -q "hypervisor" /proc/cpuinfo; then
    msg_info "VM detectada! Aplicando patch anti-tela-preta do Wayland..."
    echo "WLR_NO_HARDWARE_CURSORS=1" | sudo tee -a /etc/environment > /dev/null
fi

msg_ok "Instalação do Nucleux 100% finalizada!"

sudo reboot


REAL_USER=$Nucleux
USER_HOME="/home/$nucleux-user"

if [ -d "dotfiles" ]; then
    msg_info "Aplicando o visual do Nucleux..."
    
    mkdir -p "$USER_HOME/.config"
    
    cp -r dotfiles/* "$USER_HOME/.config/"
    
    chown -R "$REAL_USER":"$REAL_USER" "$USER_HOME/.config"
    msg_ok "Visual aplicado com sucesso!"
else
    msg_error "A pasta 'dotfiles' com as configurações não foi encontrada!"
fi
