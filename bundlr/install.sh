#!/bin/bash
echo "-----------------------------------------------------------------------------"
curl -s https://raw.githubusercontent.com/razumv/helpers/main/doubletop.sh | bash
echo "-----------------------------------------------------------------------------"

echo "-----------------------------------------------------------------------------"
echo "Устанавливаем софт"
echo "-----------------------------------------------------------------------------"
sudo apt update && sudo apt install curl -y &>/dev/null
sudo apt-get install curl wget jq libpq-dev libssl-dev build-essential pkg-config openssl ocl-icd-opencl-dev libopencl-clang-dev libgomp1 -y &>/dev/null
curl -s https://raw.githubusercontent.com/razumv/helpers/main/tools/install_ufw.sh | bash &>/dev/null
curl -s https://raw.githubusercontent.com/razumv/helpers/main/tools/install_rust.sh | bash &>/dev/null
curl -s https://raw.githubusercontent.com/razumv/helpers/main/tools/install_node14.sh | bash &>/dev/null
curl -s https://raw.githubusercontent.com/razumv/helpers/main/tools/install_docker.sh | bash &>/dev/null
echo "Весь необходимый софт установлен"
echo "-----------------------------------------------------------------------------"
mkdir $HOME/bundlr
cd $HOME/bundlr
git clone --recurse-submodules https://github.com/Bundlr-Network/validator-rust.git
cd $HOME/bundlr/validator-rust && cargo run --bin wallet-tool create > wallet.json
echo "Кошелек сгенерирован сделайте бекап кошелька и запросите токены с крана следуя указаниям в гайде"
echo "-----------------------------------------------------------------------------"
