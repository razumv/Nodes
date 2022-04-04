#!/bin/bash

echo "-----------------------------------------------------------------------------"
curl -s https://raw.githubusercontent.com/razumv/helpers/main/doubletop.sh | bash
echo "-----------------------------------------------------------------------------"
if [ ! $ALCHEMY_KEY ]; then
	read -p "Введите ваш HTTP (ПРИМЕР: https://eth-mainnet.alchemyapi.io/v2/xZXxxxxxxxxxxc2q_bzxxxxxxxxxxWTN): " ALCHEMY_KEY
fi
echo 'Ваш ключ: ' $ALCHEMY_KEY
sleep 1
echo 'export ALCHEMY_KEY='$ALCHEMY_KEY >> $HOME/.bash_profile
echo "Устанавливаем софт"
echo "-----------------------------------------------------------------------------"

sudo apt update -y
sudo apt install build-essential libssl-dev libffi-dev python3-dev screen git python3-pip python3.8-venv -y
sudo apt-get install libgmp-dev -y
pip3 install fastecdsa
sudo apt-get install -y pkg-config
curl -s https://raw.githubusercontent.com/razumv/helpers/main/tools/install_ufw.sh | bash
curl -s https://raw.githubusercontent.com/razumv/helpers/main/tools/install_rust.sh | bash
rustup update stable
source $HOME/.cargo/env
sleep 1
echo "Весь необходимый софт установлен"
echo "-----------------------------------------------------------------------------"

git clone --branch v0.1.6-alpha https://github.com/eqlabs/pathfinder.git
cd pathfinder/py
python3 -m venv .venv
source .venv/bin/activate
PIP_REQUIRE_VIRTUALENV=true pip install --upgrade pip
PIP_REQUIRE_VIRTUALENV=true pip install -r requirements-dev.txt
cargo build --release --bin pathfinder
sleep 2
source $HOME/.bash_profile
echo "Билд завершен успешно"
echo "-----------------------------------------------------------------------------"

sudo tee <<EOF >/dev/null /etc/systemd/journald.conf
Storage=persistent
EOF
sudo systemctl restart systemd-journald

sudo tee <<EOF >/dev/null /etc/systemd/system/starknet.service
[Unit]
Description=StarkNet Node
After=network.target

[Service]
Type=simple
User=$USER
WorkingDirectory=$HOME/pathfinder/py
Environment=PATH="$HOME/pathfinder/py/.venv/bin:$PATH"
ExecStart=$HOME/pathfinder/target/release/pathfinder --http-rpc=\"0.0.0.0:9545\" --ethereum.url $ALCHEMY_KEY\"
Restart=always
RestartSec=10
LimitNOFILE=10000

[Install]
WantedBy=multi-user.target
EOF

echo "Сервисные файлы созданы успешно"
echo "-----------------------------------------------------------------------------"

sudo systemctl restart systemd-journald
sudo systemctl daemon-reload
sudo systemctl enable starknet
sudo systemctl restart starknet

echo "Нода добавлена в автозагрузку на сервере, запущена"
echo "-----------------------------------------------------------------------------"
