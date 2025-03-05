#!/bin/bash

# Первая часть установки Gaianet Node
set -e

# Получаем номер ноды от пользователя
echo ""
echo -e "${NEON_BLUE}Введите номер ноды (например, 2): ${RESET}"

# Чтение ввода
read NODE_NUMBER

# Условие для создания директории для первой ноды
if [ "$NODE_NUMBER" -eq 1 ]; then
    NODE_DIR="/root/gaianet"
    NODE_NAME="gaianet"
else
    NODE_DIR="/root/gaianet-$NODE_NUMBER"
    NODE_NAME="gaianet-$NODE_NUMBER"
fi

# Создаем директорию для ноды
mkdir $NODE_DIR  # Используем -p для безопасного создания директорий

# Устанавливаем обновления системы
sudo apt update -y && sudo apt-get update -y

# Устанавливаем Gaianet
curl -sSfL 'https://github.com/GaiaNet-AI/gaianet-node/releases/latest/download/install.sh' | bash -s -- --base $NODE_DIR
