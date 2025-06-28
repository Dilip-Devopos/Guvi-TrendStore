#!/bin/bash

set -e
set -o pipefail
set -x

apt update -y
apt install curl unzip -y
# Function to check and install AWS CLI
install_aws_cli() {
    if ! command -v aws &> /dev/null; then
        echo "🔧 Installing AWS CLI..."
        curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
        unzip -q awscliv2.zip
        sudo ./aws/install
        rm -rf awscliv2.zip aws
    else
        echo "✅ AWS CLI already installed."
    fi
}

# Function to check and install kubectl
install_kubectl() {
    if ! command -v kubectl &> /dev/null; then
        echo "🔧 Installing kubectl..."
        curl -LO "https://dl.k8s.io/release/$(curl -Ls https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
        chmod +x kubectl
        sudo mv kubectl /usr/local/bin/
    else
        echo "✅ kubectl already installed."
    fi
}

# Function to check and install eksctl
install_eksctl() {
    if ! command -v eksctl &> /dev/null; then
        echo "🔧 Installing eksctl..."
        curl --silent --location "https://github.com/eksctl-io/eksctl/releases/latest/download/eksctl_$(uname -s)_amd64.tar.gz" | tar xz -C /tmp
        sudo mv /tmp/eksctl /usr/local/bin
    else
        echo "✅ eksctl already installed."
    fi
}

# Run install functions
install_aws_cli
install_kubectl
install_eksctl