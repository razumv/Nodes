#!/bin/bash
echo "-----------------------------------------------------------------------------"
curl -s https://raw.githubusercontent.com/razumv/helpers/main/doubletop.sh | bash
echo "-----------------------------------------------------------------------------"
if [ ! $UPTICK_NODENAME ]; then
	read -p "Введите ваше имя ноды(придумайте, без спецсимволов - только буквы и цифры): " UPTICK_NODENAME
fi
sleep 1
UPTICK_CHAIN="uptick_7776-1"
echo 'export UPTICK_CHAIN='$UPTICK_CHAIN >> $HOME/.profile
echo 'export UPTICK_NODENAME='$UPTICK_NODENAME >> $HOME/.profile
echo "-----------------------------------------------------------------------------"
echo "Устанавливаем софт"
echo "-----------------------------------------------------------------------------"
curl -s https://raw.githubusercontent.com/razumv/helpers/main/tools/install_ufw.sh | bash &>/dev/null
curl -s https://raw.githubusercontent.com/razumv/helpers/main/tools/install_go.sh | bash &>/dev/null
sudo apt install --fix-broken -y &>/dev/null
sudo apt install nano mc wget -y &>/dev/null
source .profile
source .bashrc
sleep 1
echo "Весь необходимый софт установлен"
echo "-----------------------------------------------------------------------------"
git clone https://github.com/UptickNetwork/uptick.git &>/dev/null
cd uptick &>/dev/null
make install &>/dev/null
echo "Репозиторий успешно склонирован, начинаем билд"
echo "-----------------------------------------------------------------------------"
uptickd config chain-id augusta-1
uptickd init $UPTICK_NODENAME --chain-id $UPTICK_CHAIN &>/dev/null
wget -O $HOME/.UPTICK/config/genesis.json "https://raw.githubusercontent.com/kuraassh/uptick-testnet/main/uptick_7776-1/genesis.json"
sed -i.bak -e "s%^moniker *=.*%moniker = \"$UPTICK_NODENAME\"%; "\
"s%^seeds *=.*%seeds = \"7aad751eb956d65388f0cc37ab2ea179e2143e41@seed0.testnet.uptick.network:26656,7e6c759bcf03641c65659f1b9b2f05ec9de7391b@seed1.testnet.uptick.network:26656\"%; "\
"s%^persistent_peers *=.*%persistent_peers = \"f046ee3ead7e709b0fd6d5b30898e96959c1144d@peer0.testnet.uptick.network:26656,02ee3a0f3a2002d11c5eeb7aa813b64c59d6b60e@peer1.testnet.uptick.network:26656\"%; "\
"s%^external_address *=.*%external_address = \"`wget -qO- eth0.me`:26656\"%; "
$HOME/.uptickd/config/config.toml
sed -i.bak -e "s/indexer = "kv"/indexer = "null"/g"%; "\
"s%^pruning = "default"=.*%pruning =\"custom"/g"%; "\
"s%^pruning-keep-recent = "0"=.*%pruning-keep-recent =\"100"/g"%; "\
"s%^pruning-keep-every = "0"=.*%pruning-keep-every =\"0"/g"%; "\
"s%^pruning-interval = "0"=.*%pruning-interval =\"10"/g"%; "
$HOME/.uptickd/config/app.toml
echo "Билд закончен, переходим к инициализации ноды"
echo "-----------------------------------------------------------------------------"
sudo tee <<EOF >/dev/null /etc/systemd/journald.conf
Storage=persistent
EOF
sudo systemctl restart systemd-journald

sudo tee <<EOF >/dev/null /etc/systemd/system/uptickd.service
[Unit]
  Description=UPTICK Cosmos daemon
  After=network-online.target
[Service]
  User=$USER
  ExecStart=$(which uptickd) start
  Restart=on-failure
  RestartSec=3
  LimitNOFILE=4096
[Install]
  WantedBy=multi-user.target
EOF

sudo systemctl enable uptickd &>/dev/null
sudo systemctl daemon-reload
sudo systemctl restart uptickd

echo "Validator Node $UPTICK_NODENAME успешно установлена"
echo "-----------------------------------------------------------------------------"
