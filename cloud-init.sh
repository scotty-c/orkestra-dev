#!/usr/bin/env bash
set -ex pipefail

export DEBIAN_FRONTEND=noninteractive

echo "# make..."
sudo apt-get install -y \
        make

echo "# microk8s..."
sudo snap install microk8s --classic --channel=1.19
mkdir -p $HOME/.kube/
sudo usermod -a -G microk8s $USER
sudo chown -f -R $USER ~/.kube
sudo microk8s config > $HOME/.kube/config

tee -a ~/.bash_aliases <<'EOF'
function kubectl {
        sudo microk8s kubectl "$@"
}
PATH="$PATH:/usr/local/go/bin:'$HOME'/go/bin"
EOF
source ~/.bash_aliases

echo " # Helm..."
curl https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3 | bash

echo "# lazygit..."
sudo add-apt-repository --yes ppa:lazygit-team/release
sudo apt-get update
sudo apt-get install -y lazygit

echo "# golang..."
VERSION='1.15.11'
OS='linux'
ARCH='amd64'

curl -OL https://dl.google.com/go/go${VERSION}.${OS}-${ARCH}.tar.gz
sudo tar -C /usr/local -xzf go$VERSION.$OS-$ARCH.tar.gz
rm go$VERSION.$OS-$ARCH.tar.gz

echo "# kubebuilder..."
curl -L -o kubebuilder https://go.kubebuilder.io/dl/latest/$(go env GOOS)/$(go env GOARCH)
chmod +x kubebuilder && mv kubebuilder /usr/local/bin/


echo "# controller-gen..."
GO111MODULE=on go get -v -u sigs.k8s.io/controller-tools/cmd/controller-gen@v0.5.0
sudo chown -f -R $USER $HOME/go

echo "# orkestra..."
git clone https://github.com/Azure/orkestra.git
cd orkestra && helm install orkestra chart/orkestra/ --namespace orkestra --create-namespace

echo "# complete!"