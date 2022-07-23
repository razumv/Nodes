#!/bin/bash

echo "-----------------------------------------------------------------------------"
curl -s https://raw.githubusercontent.com/razumv/helpers/main/doubletop.sh | bash
echo "-----------------------------------------------------------------------------"
if [ ! $BUNDLR_ADDR ]; then
	read -p "Введите ваш адрес кошелька (в формате - JunMG4mGXSHN3WR-qiioGsGDn7mhQjlb2d4fCUQYfjg): " BUNDLR_ADDR
fi
echo 'Ваше имя ноды: ' $BUNDLR_ADDR
sleep 1
BUNDLR_PORT=2109
echo "export BUNDLR_PORT="${BUNDLR_PORT}"" >> $HOME/.profile
echo 'export BUNDLR_ADDR='$BUNDLR_ADDR >> $HOME/.profile
echo "-----------------------------------------------------------------------------"
sudo tee <<EOF >/dev/null $HOME/bundlr/validator-rust/.env
PORT=${BUNDLR_PORT}
VALIDATOR_KEY=./wallet.json
BUNDLER_URL=https://testnet1.bundlr.network
GW_WALLET=./wallet.json
GW_CONTRACT=RkinCLBlY4L5GZFv8gCFcrygTyd5Xm91CzKlR6qxhKA
GW_ARWEAVE=https://arweave.testnet1.bundlr.network
EOF
cd $HOME/bundlr/validator-rust && docker-compose up -d

echo "BUNDLR успешно установлен, проверьте логи командой docker-compose -f $HOME/bundlr/validator-rust logs -f --tail=100"
echo "-----------------------------------------------------------------------------"
