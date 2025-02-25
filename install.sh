#!/bin/bash

# Define colors
RED='\e[31m'
GREEN='\e[32m'
YELLOW='\e[33m'
CYAN='\e[36m'
WHITE='\e[37m'
RESET='\e[0m'
GRAY='\033[0;37m'

echo -e "\n${CYAN}███╗   ███╗██╗   ██╗███╗   ██╗███╗   ███╗ █████╗ ██████╗ 
████╗ ████║╚██╗ ██╔╝████╗  ██║████╗ ████║██╔══██╗██╔══██╗
██╔████╔██║ ╚████╔╝ ██╔██╗ ██║██╔████╔██║███████║██████╔╝
██║╚██╔╝██║  ╚██╔╝  ██║╚██╗██║██║╚██╔╝██║██╔══██║██╔═══╝ 
██║ ╚═╝ ██║   ██║   ██║ ╚████║██║ ╚═╝ ██║██║  ██║██║     
╚═╝     ╚═╝   ╚═╝   ╚═╝  ╚═══╝╚═╝     ╚═╝╚═╝  ╚═╝╚═╝ ${RESET}Made by ${CYAN}Diego Becker${RESET}.\n"

echo "THIS TOOL IS MADE ONLY FOR EDUCATIONAL AND RESEARCH PURPOUSES ONLY I DO NOT ASSUME
ANY KIND OF RESPONSIBILITY FOR ANY IMPROPE USE OF THIS TOOL USE IT WITH GOOD SENSE."

echo "Starting installation of dependencies..."

# Verificar gerenciador de pacotes
echo -e "\n${CYAN}Detecting package manager...${RESET}"

if command -v apt &>/dev/null; then
  echo -e "${GREEN}APT detected (Debian/Ubuntu/Kali)${RESET}"
  UPDATE_CMD="sudo apt update"
  INSTALL_CMD="sudo apt install -y"
  PACKAGES="nmap tor proxychains bat"
elif command -v pacman &>/dev/null; then
  echo -e "${GREEN}Pacman detected (Arch/Manjaro)${RESET}"
  UPDATE_CMD="sudo pacman -Sy"
  INSTALL_CMD="sudo pacman -S --noconfirm"
  PACKAGES="nmap tor proxychains-ng bat"
elif command -v dnf &>/dev/null || command -v yum &>/dev/null; then
  echo -e "${GREEN}DNF/YUM detected (Fedora/RHEL/CentOS)${RESET}"
  if command -v dnf &>/dev/null; then
    INSTALL_CMD="sudo dnf install -y"
  else
    INSTALL_CMD="sudo yum install -y"
  fi
  UPDATE_CMD="sudo $INSTALL_CMD epel-release && sudo $INSTALL_CMD update"
  PACKAGES="nmap tor proxychains-ng"
  PKG_MANAGER="redhat"
else
  echo -e "${RED}Unsupported system. Only APT, Pacman, DNF/YUM based distributions are supported.${RESET}"
  exit 1
fi

# Atualizar pacotes
echo -e "\n${CYAN}Updating packages...${RESET}"
echo -e "${GRAY}Executing: ${UPDATE_CMD}${RESET}"
eval $UPDATE_CMD

# Instalar dependências
echo -e "\n${CYAN}Installing dependencies...${RESET}"
echo -e "${GRAY}Packages to install: ${PACKAGES}${RESET}"
echo -e "${GRAY}Executing: ${INSTALL_CMD} ${PACKAGES}${RESET}"
eval $INSTALL_CMD $PACKAGES

# Verifica instalação do bat após instalação dos pacotes
echo -e "\n${CYAN}Verifying bat installation...${RESET}"
if ! command -v bat &>/dev/null && [ "$PKG_MANAGER" = "redhat" ]; then
  echo -e "${YELLOW}Bat not found in repositories, installing via Cargo...${RESET}"
  
  # Instalar Rust se necessário
  if ! command -v cargo &>/dev/null; then
    echo -e "${CYAN}Installing Rust...${RESET}"
    
    # Tentar instalar via repositórios primeiro
    if sudo $INSTALL_CMD cargo 2>/dev/null; then
      echo -e "${GREEN}Cargo instalado via repositórios${RESET}"
    else
      echo -e "${YELLOW}Instalando via Rustup...${RESET}"
      curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
      source "$HOME/.cargo/env"
    fi
  fi
  
  # Instalar bat via Cargo
  echo -e "${CYAN}Building bat from source...${RESET}"
  cargo install bat --locked
  
  # Criar symlink global
  echo -e "${CYAN}Creating system symlink...${RESET}"
  sudo ln -svf "$HOME/.cargo/bin/bat" /usr/local/bin/batcat
fi

# Link do mynmap
echo -e "\n${CYAN}Creating mynmap symlink...${RESET}"
echo -e "${GRAY}Linking: $(pwd)/mynmap → /usr/local/bin/mynmap${RESET}"
sudo ln -sv $(pwd)/mynmap /usr/local/bin/mynmap

echo -e "\n${GREEN}Finalizing permissions...${RESET}"
sudo chmod -v 770 ./mynmap
