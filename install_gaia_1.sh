#!/bin/bash

# Цветовые коды
NEON_RED='\033[38;5;196m'
NEON_BLUE='\033[38;5;45m'
RESET='\033[0m'

# Логотип
logo() {
    echo -e "
${NEON_RED}  ____   ${NEON_BLUE}____  
${NEON_RED} |  _ \\  ${NEON_BLUE}|  _ \\ 
${NEON_RED} | | | | ${NEON_BLUE}| |_) |
${NEON_RED} | |_| | ${NEON_BLUE}|  __/ 
${NEON_RED} |____/  ${NEON_BLUE}|_|    
${NEON_RESET}
"
}

# Вызов логотипа
logo
echo -e "${NEON_BLUE}https://t.me/DropPredator${RESET}"
# Основная логика
echo -e "${NEON_RED}Welcome to DP Script!${RESET}"

# Первая часть установки Gaianet Node
set -e

# Получаем номер ноды от пользователя
read -p "${NEON_BLUE}Введите номер ноды (например, 2)${RESET}: " NODE_NUMBER

# Создаем директорию для ноды
NODE_DIR="/root/gaianet-$NODE_NUMBER"
mkdir -p $NODE_DIR

# Устанавливаем обновления системы
sudo apt update -y && sudo apt-get update -y

# Устанавливаем Gaianet
curl -sSfL 'https://github.com/GaiaNet-AI/gaianet-node/releases/latest/download/install.sh' | bash -s -- --base $NODE_DIR
