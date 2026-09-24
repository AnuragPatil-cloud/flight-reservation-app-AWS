# AWS Credentials

Do NOT place AWS access key IDs or secret access keys in `terraform.tfvars`.

Use AWS CLI configuration on the machine running Terraform:

```bash
aws configure
aws sts get-caller-identity
```

Or use an AWS profile/environment/IAM role. Terraform automatically uses the AWS SDK credential chain.

The `terraform.tfvars` file is for project variables and sensitive application secrets such as the RDS and Grafana passwords; it is excluded by `.gitignore`.
