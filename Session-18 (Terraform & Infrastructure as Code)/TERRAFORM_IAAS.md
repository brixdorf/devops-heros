# Terraform & Infrastructure as Code Homework

## Task 1: Terraform S3 Demo

Built a Terraform project that creates a private, encrypted, versioned S3 bucket in `ap-south-1` (Mumbai), and ran the whole workflow on it: `init`, `fmt`, `validate`, `plan`, `apply`, `show`, `output`, `destroy`.

```text
terraform-s3-demo/
├── main.tf
├── variables.tf
├── outputs.tf
├── provider.tf
├── terraform.tfvars
└── README.md
```

Step by step commands, explanations and screenshots are in [terraform-s3-demo/README.md](terraform-s3-demo/README.md).

## Task 2: AWS Services Research

One README per service:

| Folder | Service | Category |
|---|---|---|
| [01-iam](aws-services/01-iam/README.md) | IAM | Governance |
| [02-ec2](aws-services/02-ec2/README.md) | EC2 | Compute |
| [03-s3](aws-services/03-s3/README.md) | S3 | Storage |
| [04-vpc](aws-services/04-vpc/README.md) | VPC | Networking |
| [05-dynamodb-rds](aws-services/05-dynamodb-rds/README.md) | DynamoDB and RDS | Databases |
