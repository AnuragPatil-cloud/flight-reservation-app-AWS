#!/bin/bash
set -euxo pipefail

dnf update -y
dnf install -y curl wget unzip git tar docker
systemctl enable --now docker
usermod -aG docker ec2-user || true

# AWS CLI v2
curl -fsSL "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o /tmp/awscliv2.zip
rm -rf /tmp/aws && unzip -q /tmp/awscliv2.zip -d /tmp
/tmp/aws/install --update || true

# kubectl
KUBECTL_VERSION="$(curl -fsSL https://dl.k8s.io/release/stable.txt)"
curl -fsSLo /usr/local/bin/kubectl "https://dl.k8s.io/release/$${KUBECTL_VERSION}/bin/linux/amd64/kubectl"
chmod +x /usr/local/bin/kubectl

# Helm
curl -fsSL https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash

# Argo CD CLI
ARGO_VERSION="$(curl -fsSL https://api.github.com/repos/argoproj/argo-cd/releases/latest | grep 'tag_name' | head -1 | cut -d'"' -f4)"
curl -fsSL -o /usr/local/bin/argocd "https://github.com/argoproj/argo-cd/releases/download/$${ARGO_VERSION}/argocd-linux-amd64"
chmod +x /usr/local/bin/argocd

mkdir -p /opt/monitoring/grafana/provisioning/datasources
cat > /opt/monitoring/prometheus.yml <<'PROM'
global:
  scrape_interval: 15s
scrape_configs:
  - job_name: prometheus
    static_configs:
      - targets: ["localhost:9090"]
PROM

cat > /opt/monitoring/grafana/provisioning/datasources/prometheus.yml <<'GRAFANA_DS'
apiVersion: 1
datasources:
  - name: Prometheus
    type: prometheus
    access: proxy
    url: http://prometheus:9090
    isDefault: true
    editable: true
GRAFANA_DS

docker network create monitoring 2>/dev/null || true
docker volume create prometheus_data
docker volume create grafana_data
docker rm -f prometheus grafana 2>/dev/null || true

docker run -d --name prometheus --restart unless-stopped \
  --network monitoring \
  -p 9090:9090 \
  -v /opt/monitoring/prometheus.yml:/etc/prometheus/prometheus.yml:ro \
  -v prometheus_data:/prometheus \
  prom/prometheus:latest

docker run -d --name grafana --restart unless-stopped \
  --network monitoring \
  -p 3000:3000 \
  -e GF_SECURITY_ADMIN_USER=admin \
  -e GF_SECURITY_ADMIN_PASSWORD="${GRAFANA_ADMIN_PASSWORD}" \
  -v grafana_data:/var/lib/grafana \
  -v /opt/monitoring/grafana/provisioning:/etc/grafana/provisioning:ro \
  grafana/grafana:latest
