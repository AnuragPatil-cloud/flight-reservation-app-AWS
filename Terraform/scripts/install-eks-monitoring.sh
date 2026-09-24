#!/bin/bash
set -euo pipefail

: "${AWS_REGION:?Set AWS_REGION, for example ap-south-1}"
: "${EKS_CLUSTER_NAME:?Set EKS_CLUSTER_NAME}"

aws eks update-kubeconfig --region "$AWS_REGION" --name "$EKS_CLUSTER_NAME"

helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update

kubectl create namespace monitoring --dry-run=client -o yaml | kubectl apply -f -

helm upgrade --install monitoring prometheus-community/kube-prometheus-stack \
  --namespace monitoring \
  --set grafana.enabled=true \
  --set prometheus.prometheusSpec.retention=7d \
  --set alertmanager.enabled=true \
  --wait --timeout 10m

kubectl get pods -n monitoring
kubectl get svc -n monitoring
