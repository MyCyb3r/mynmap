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
  PACKAGES="nmap tor proxychains bat"
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

# Verifica se o batcat está disponível
echo -e "\n${CYAN}Verifying batcat installation...${RESET}"
if ! command -v batcat &>/dev/null; then
  if command -v bat &>/dev/null; then
    echo -e "${GRAY}Creating symlink: bat → batcat${RESET}"
    sudo ln -s $(which bat) /usr/local/bin/batcat
  else
    echo -e "${RED}batcat/bat not found in PATH:${RESET}"
    echo -e "${GRAY}$(ls -l /usr/bin/bat* 2>/dev/null)${RESET}"
    exit 1
  fi
fi

# Link do mynmap
sudo rm /usr/local/bin/mynmap
echo -e "\n${CYAN}Creating mynmap symlink...${RESET}"
echo -e "${GRAY}Linking: $(pwd)/mynmap → /usr/local/bin/mynmap${RESET}"
sudo ln -sv $(pwd)/mynmap /usr/local/bin/mynmap

echo -e "\n${GREEN}Finalizing permissions...${RESET}"
sudo chmod -v 770 ./mynmap
