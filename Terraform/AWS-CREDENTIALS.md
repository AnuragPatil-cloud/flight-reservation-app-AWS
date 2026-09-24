# AWS Credentials

Do not put AWS access keys or secret keys in `terraform.tfvars`.

Use an IAM role on EC2 where possible. For a dedicated Terraform administration host, an AWS CLI profile may be used:

```bash
aws configure
aws sts get-caller-identity
```

Keep `terraform.tfvars` out of Git because it contains environment-specific and sensitive values such as the RDS password.
