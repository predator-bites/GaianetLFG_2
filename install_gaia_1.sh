#!/bin/bash

# Первая часть установки Gaianet Node
set -e

# Получаем номер ноды от пользователя
read -p "Введите номер ноды (например, 2): " NODE_NUMBER

# Создаем директорию для ноды
NODE_DIR="/root/gaianet-$NODE_NUMBER"
mkdir -p $NODE_DIR

# Устанавливаем обновления системы
sudo apt update -y && sudo apt-get update -y

# Устанавливаем Gaianet
curl -sSfL 'https://github.com/GaiaNet-AI/gaianet-node/releases/latest/download/install.sh' | bash -s -- --base $NODE_DIR

# Завершаем первую часть установки
echo "Первая часть установки завершена. Запустите следующий скрипт после выполнения команды source /root/.bashrc"
