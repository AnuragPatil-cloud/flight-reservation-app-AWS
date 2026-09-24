# Flight Reservation - AWS Terraform

This Terraform layout is based on the uploaded Azure Flight Reservation project and ports the infrastructure pattern to AWS.

## Target architecture

- EC2 VM1: `c7i-flex.large` for Jenkins, Docker and SonarQube
- EC2 VM2: `c7i-flex.large` administration/monitoring host for kubectl, Helm and Argo CD CLI
- EKS: two `c7i-flex.large` worker nodes
- Amazon RDS MariaDB: private database, replacing the Kubernetes MariaDB/PVC
- Amazon S3: private important-file/object storage
- Amazon ECR: reservation, check-in and frontend repositories
- Amazon SNS: CloudWatch alarm notifications
- Amazon CloudWatch: EC2 and RDS alarms
- Prometheus/Grafana: installed in EKS with Helm from VM2, matching the original project workflow

## Naming

Resources follow `flight-reservation-dev-*` naming where AWS naming rules allow it.

## Apply order

1. Configure AWS credentials outside Terraform variables.
2. Fill `terraform.tfvars`.
3. `terraform init`
4. `terraform fmt -recursive`
5. `terraform validate`
6. `terraform plan`
7. Review the plan.
8. Only then run `terraform apply`.

## RDS databases

The RDS instance creates `flightdb` from Terraform. Create `checkin_db` as a follow-up SQL initialization step after RDS is reachable from the private network.

## Monitoring

VM2 is the administration host. Prometheus and Grafana are intended to run in the EKS monitoring namespace using the Prometheus Community Helm chart, while VM2 provides `kubectl`, Helm and Argo CD access.
