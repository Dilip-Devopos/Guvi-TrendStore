#!/bin/bash

set -e
set -o pipefail
set -x

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

# Set cluster name and region
CLUSTER_NAME="your-cluster-name"
REGION="your-region"  # e.g., us-east-1

# Update kubeconfig
echo "🔗 Connecting to EKS cluster: $CLUSTER_NAME..."
aws eks update-kubeconfig --region "$REGION" --name "$CLUSTER_NAME"

# Apply manifests
echo "🚀 Deploying Kubernetes manifests..."
kubectl apply -f deployment.yml
kubectl apply -f service.yml

echo "✅ Deployment complete."

NAMESPACE=default

# Define your deployment and service names
DEPLOYMENT_NAME=trend-app-deployment
SERVICE_NAME=trend-app-service

# Define your YAML paths
DEPLOYMENT_YAML=deployment.yml
SERVICE_YAML=service.yml

echo "Checking if deployment '$DEPLOYMENT_NAME' exists..."
if kubectl get deployment "$DEPLOYMENT_NAME" -n "$NAMESPACE" &> /dev/null; then
    echo "Deployment '$DEPLOYMENT_NAME' exists. Deleting it..."
    kubectl delete deployment "$DEPLOYMENT_NAME" -n "$NAMESPACE"
    sleep 5  # Optional: wait for cleanup
else
    echo "Deployment '$DEPLOYMENT_NAME' does not exist. Skipping delete."
fi

echo "Applying deployment YAML..."
kubectl apply -f "$DEPLOYMENT_YAML" -n "$NAMESPACE"

echo "Checking if service '$SERVICE_NAME' exists..."
if kubectl get service "$SERVICE_NAME" -n "$NAMESPACE" &> /dev/null; then
    echo "Service '$SERVICE_NAME' exists. Skipping apply."
else
    echo "Service '$SERVICE_NAME' does not exist. Applying service YAML..."
    kubectl apply -f "$SERVICE_YAML" -n "$NAMESPACE"
fi