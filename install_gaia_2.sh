#!/bin/bash
NEON_BLUE='\033[38;5;45m'
NEON_RED= '\033[38;5;196m'
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

set -e

# Получаем номер ноды от пользователя
read -p "Введите номер ноды (например, 1): " NODE_NUMBER

# Для первой ноды устанавливаем параметры
if [ "$NODE_NUMBER" -eq 1 ]; then
    NODE_DIR="/root/gaianet"
    LLAMAEDGE_PORT=8080
    SERVICE_FILE="/etc/systemd/system/gaianet.service"
    SESSION_NAME="faker_session"
else
    NODE_DIR="/root/gaianet-$NODE_NUMBER"
    LLAMAEDGE_PORT=$((8080 + (NODE_NUMBER - 1) * 5))
    SERVICE_FILE="/etc/systemd/system/gaianet-$NODE_NUMBER.service"
    SESSION_NAME="faker_session_$NODE_NUMBER"
fi

# Проверяем наличие директории
if [ ! -d "$NODE_DIR" ]; then
  echo "Директория $NODE_DIR не найдена. Убедитесь, что вы выполнили первый скрипт."
  exit 1
fi

# Инициализируем ноду
gaianet init --config "https://raw.gaianet.ai/qwen2-0.5b-instruct/config.json" --base $NODE_DIR

# Настраиваем порт в конфигурации
sed -i "s/\"llamaedge_port\": \"8080\"/\"llamaedge_port\": \"$LLAMAEDGE_PORT\"/" "$NODE_DIR/config.json"

# Настраиваем службу systemd
cat <<EOL | sudo tee $SERVICE_FILE
[Unit]
Description=Gaianet Node Service $NODE_NUMBER
After=network.target

[Service]
Type=forking
RemainAfterExit=true
ExecStart=$NODE_DIR/bin/gaianet start --base $NODE_DIR
ExecStop=$NODE_DIR/bin/gaianet stop --base $NODE_DIR
ExecStopPost=/bin/sleep 20
Restart=always
RestartSec=5
User=root

[Install]
WantedBy=multi-user.target
EOL

sleep 5 

# Применяем изменения
sudo systemctl daemon-reload
sudo systemctl restart gaianet-$NODE_NUMBER.service
sudo systemctl enable gaianet-$NODE_NUMBER.service

# Сохраняем информацию о ноде
gaianet info > "$NODE_DIR/gaianet_info.txt"
NODE_ID=$(grep 'Node ID:' "$NODE_DIR/gaianet_info.txt" | awk '{print $3}' | sed 's/[^a-zA-Z0-9]//g' | cut -c1-42)

# Устанавливаем дополнительные инструменты
sudo apt install -y python3-pip nano screen
pip install requests faker

# Создаем Python-скрипт общения с нодой
cat <<EOL > "/root/random_chat_with_faker_$NODE_NUMBER.py"
import requests
import random
import logging
import time
from faker import Faker
from datetime import datetime

node_url = "https://$NODE_ID.gaia.domains/v1/chat/completions"

faker = Faker()

headers = {
    "accept": "application/json",
    "Content-Type": "application/json"
}

logging.basicConfig(filename='chat_log_$NODE_NUMBER.txt', level=logging.INFO, format='%(asctime)s - %(message)s')

def log_message(node, message):
    logging.info(f"{node}: {message}")

def send_message(node_url, message):
    try:
        response = requests.post(node_url, json=message, headers=headers)
        response.raise_for_status()
        return response.json()
    except requests.exceptions.RequestException as e:
        print(f"Failed to get response from API: {e}")
        return None

def extract_reply(response):
    if response and 'choices' in response:
        return response['choices'][0]['message']['content']
    return ""

while True:
    random_question = faker.sentence(nb_words=10)
    message = {
        "messages": [
            {"role": "system", "content": "You are a helpful assistant."},
            {"role": "user", "content": random_question}
        ]
    }

    question_time = datetime.now().strftime("%Y-%m-%d %H:%M:%S")

    response = send_message(node_url, message)
    reply = extract_reply(response)

    reply_time = datetime.now().strftime("%Y-%m-%d %H:%M:%S")

    log_message("Node replied", f"Q ({question_time}): {random_question} A ({reply_time}): {reply}")

    print(f"Q ({question_time}): {random_question}\nA ({reply_time}): {reply}")

    delay = random.randint(1, 3)
    time.sleep(delay)
EOL

# Запуск Python-скрипта в screen
screen -dmS "$SESSION_NAME" bash -c "python3 $CHAT_SCRIPT"


# Инструкция для пользователя с перекрашиванием в неоновый красный
echo -e "${NEON_RED}"
cat << EOF
Установка завершена!
- Node ID: $NODE_ID
- Конфигурация сохранена в: $NODE_DIR/config.json
- Лог общения: chat_log_$NODE_NUMBER.txt

Для подключения к screen-сессии:
  screen -r $SESSION_NAME

Чтобы выйти из сессии, не останавливая скрипт:
  Нажмите Ctrl+A, затем D.
EOF
echo -e "${RESET}"

# Логотип и ссылка
logo
echo -e "${NEON_BLUE}https://t.me/DropPredator${RESET}"
