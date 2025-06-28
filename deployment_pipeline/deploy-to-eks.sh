#!/bin/bash
set -e
set -x

# Set cluster name and region
CLUSTER_NAME="your-cluster-name"
REGION="your-region"  # e.g., us-east-1

# Update kubeconfig
echo "🔗 Connecting to EKS cluster: $CLUSTER_NAME..."
aws eks update-kubeconfig --region "$REGION" --name "$CLUSTER_NAME"

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

echo "✅ Deployment complete."