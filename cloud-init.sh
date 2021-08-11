#!/usr/bin/env bash
set -ex pipefail

export DEBIAN_FRONTEND=noninteractive

echo "# make..."
sudo apt-get install -y \
        make

echo "# microk8s..."
sudo snap install microk8s --classic --channel=1.21
mkdir -p $HOME/.kube/
sudo usermod -a -G microk8s $USER
sudo chown -f -R $USER ~/.kube
sudo microk8s config > $HOME/.kube/config
sudo microk8s enable dns

tee -a ~/.bash_aliases <<'EOF'
function kubectl {
        sudo microk8s kubectl "$@"
}
source <(kubectl completion bash)
EOF
source ~/.bash_aliases

echo " # Helm..."
curl https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3 | bash

echo "# orkestra..."
git clone https://github.com/Azure/orkestra.git
cd orkestra && helm install orkestra chart/orkestra/ --namespace orkestra --create-namespace

echo "# complete!"