#!/usr/bin/env bash
set -euo pipefail

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
sudo microk8s enable helm3

tee -a ~/.bash_aliases <<'EOF'
function helm {
        sudo microk8s helm3 "$@"
}

function kubectl {
        sudo microk8s kubectl "$@"
}
EOF
source ~/.bash_aliases

echo "# k9s..."
VERSION='0.24.2':w

curl -OL https://github.com/derailed/k9s/releases/download/v${VERSION}/k9s_Linux_x86_64.tar.gz
mkdir -p tmp/
tar -C tmp/ -xvf k9s_Linux_x86_64.tar.gz
rm k9s_Linux_x86_64.tar.gz
sudo mv -f tmp/k9s /usr/local/bin
rm -rf tmp/
mkdir -p $HOME/.k9s/

echo "# lazygit..."
sudo add-apt-repository --yes ppa:lazygit-team/release
sudo apt-get update
sudo apt-get install -y lazygit

echo "# golang..."
VERSION='1.16'
OS='linux'
ARCH='amd64'

curl -OL https://dl.google.com/go/go${VERSION}.${OS}-${ARCH}.tar.gz
sudo tar -C /usr/local -xzf go$VERSION.$OS-$ARCH.tar.gz
rm go$VERSION.$OS-$ARCH.tar.gz

echo 'PATH="$PATH:/usr/local/go/bin:'$HOME'/go/bin"' >> ~/.bash_aliases

echo "# kubebuilder..."
curl -L -o kubebuilder https://go.kubebuilder.io/dl/latest/$(go env GOOS)/$(go env GOARCH)
chmod +x kubebuilder && mv kubebuilder /usr/local/bin/


echo "#controller-gen..."
GO111MODULE=on go get -v -u sigs.k8s.io/controller-tools/cmd/controller-gen@v0.5.0

echo "#orkestra..."
helm install orkestra chart/orkestra/  --namespace orkestra --create-namespace

echo "# complete!"