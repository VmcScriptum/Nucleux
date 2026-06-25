#!/usr/bin/env bash

# 1. PARADA DE EMERGÊNCIA: Se qualquer comando der erro, o script morre na hora. 
# (Sem isso, se a internet cair no meio do download do driver, ele continua rodando e destrói o sistema).
set -e

# 2. Paleta de cores para o terminal (dar aquele visual de "Hacker de cinema")
VERDE='\033[0;32m'
VERMELHO='\033[0;31m'
AZUL='\033[0;34m'
AMARELO='\033[1;33m'
RESET='\033[0m'

# Funções de padronização de mensagens
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
echo -e "${VERDE}"
echo "================================================="
echo "        INSTALADOR DO MEU ARCH v0.1              "
echo "================================================="
echo -e "${RESET}"

# 3. VERIFICAÇÃO 1: O usuário cometeu o erro de rodar como 'sudo ./install.sh'?
if [[ $EUID -eq 0 ]]; then
   msg_erro "Este script NÃO pode ser rodado como root! Execute apenas: ./install.sh"
fi

# 4. VERIFICAÇÃO 2: Tem internet?
msg_info "Testando conexão com os servidores do Arch..."
if ! ping -c 1 archlinux.org &> /dev/null; then
    msg_erro "Sem conexão com a internet. Verifique sua rede na VM e tente de novo."
fi
msg_ok "Conexão com a internet confirmada."

# 5. VERIFICAÇÃO 3: O pacman está travado por outra atualização em segundo plano?
if [ -f /var/lib/pacman/db.lck ]; then
    msg_info "Trava do Pacman encontrada. Removendo..."
    sudo rm /var/lib/pacman/db.lck
    msg_ok "Trava removida."
fi

msg_ok "Ambiente verificado com sucesso. Pronto para iniciar a instalação."
