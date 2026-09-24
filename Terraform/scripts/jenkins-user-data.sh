#!/bin/bash
set -euxo pipefail

dnf update -y
dnf install -y java-21-amazon-corretto wget git curl unzip tar docker
systemctl enable --now docker
usermod -aG docker ec2-user || true

mkdir -p /etc/yum.repos.d
curl -fsSL https://pkg.jenkins.io/redhat-stable/jenkins.repo -o /etc/yum.repos.d/jenkins.repo
rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io-2026.key || true
dnf install -y jenkins
systemctl enable --now jenkins

mkdir -p /opt/sonarqube
cat > /opt/sonarqube/docker-compose.yml <<'COMPOSE'
services:
  sonarqube:
    image: sonarqube:lts-community
    container_name: sonarqube
    restart: unless-stopped
    ports:
      - "9000:9000"
    volumes:
      - sonarqube_data:/opt/sonarqube/data
      - sonarqube_logs:/opt/sonarqube/logs
      - sonarqube_extensions:/opt/sonarqube/extensions
volumes:
  sonarqube_data:
  sonarqube_logs:
  sonarqube_extensions:
COMPOSE
cd /opt/sonarqube
docker compose version >/dev/null 2>&1 || true
docker pull sonarqube:lts-community
docker run -d --name sonarqube --restart unless-stopped -p 9000:9000 sonarqube:lts-community || docker start sonarqube || true
