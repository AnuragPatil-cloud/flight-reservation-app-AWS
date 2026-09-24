# AWS Flight Reservation - Modular Terraform

This folder provisions the AWS infrastructure for the Flight Reservation project.

## Target architecture

- VM1: `c7i-flex.large` EC2 with Jenkins + Docker + SonarQube
- VM2: `c7i-flex.large` EC2 with AWS CLI + kubectl + Helm + Argo CD CLI + Prometheus + Grafana
- EKS: 2 managed worker nodes, both `c7i-flex.large`
- RDS: private MariaDB; replaces Kubernetes MariaDB Deployment/PVC
- S3: private, versioned, encrypted object storage for important application files
- ECR: `flight-reservation-app`, `flight-checkin-app`, `flight-frontend`
- SNS: email notification topic
- CloudWatch: EC2 CPU and RDS CPU/storage alarms

## Credentials

Do not put AWS access keys or secret keys into Terraform files. Authenticate Terraform using the AWS CLI/profile or an IAM role:

```bash
aws configure
aws sts get-caller-identity
```

`terraform.tfvars` contains sensitive values such as the RDS and Grafana passwords. It is gitignored. Never commit it.

## Deploy

```bash
terraform init
terraform fmt -recursive
terraform validate
terraform plan -out=flight-reservation.tfplan
terraform apply flight-reservation.tfplan
```

After the EKS cluster is available, VM2 can connect to the private EKS API:

```bash
aws eks update-kubeconfig --name <EKS_CLUSTER_NAME> --region <AWS_REGION>
kubectl get nodes
```

The monitoring EC2 role is granted an EKS cluster access entry with AmazonEKSClusterAdminPolicy so VM2 can administer the cluster.

## RDS

Terraform creates the initial database specified by `rds_database_name` (default `flightdb`). Create `checkin_db` as a controlled follow-up step from a host that can reach RDS; do not run MariaDB/PVC resources in EKS.

Example:

```sql
CREATE DATABASE checkin_db;
```

## ECR / Jenkins

Jenkins VM has an IAM instance profile with AmazonEC2ContainerRegistryPowerUser. Jenkins can authenticate with ECR using:

```bash
aws ecr get-login-password --region <AWS_REGION> | docker login --username AWS --password-stdin <ACCOUNT_ID>.dkr.ecr.<AWS_REGION>.amazonaws.com
```

Build/push the three project images and update the GitOps image references for Argo CD.

## SNS

SNS sends an email subscription confirmation after apply. Confirm that message before expecting CloudWatch alarm emails.

## Notes

- The EKS endpoint is private-only; administer it from VM2 or another host inside the VPC.
- The first Terraform apply creates the core infrastructure. Kubernetes add-ons and application manifests are a separate deployment phase.
- Prometheus/Grafana on VM2 start with a local Prometheus target and a preconfigured Grafana Prometheus datasource. EKS Kubernetes scraping is configured after EKS is ready.
- For production, replace node-level S3 permissions with EKS Pod Identity/IRSA scoped to the application service account.

## Create the second RDS database

RDS supports one initial database through `db_name`. After RDS is reachable from VM1/VM2, install a MySQL/MariaDB client and run:

```bash
./scripts/create-checkin-db.sh <RDS_ENDPOINT> <RDS_USER> '<RDS_PASSWORD>' checkin_db
```

Do not place the real password in Git.
