# Terraform S3 Demo

Creates one private, encrypted, versioned S3 bucket (plus a small test file in it) with Terraform, then walks through the full Terraform workflow from `init` to `destroy`.

Terraform is an Infrastructure as Code (IaC) tool: instead of clicking through the AWS console, I describe the infrastructure I want in `.tf` files, and Terraform works out which API calls are needed to make AWS match that description.

## Files

| File | Purpose |
|---|---|
| `provider.tf` | Required Terraform version, the `aws` and `random` providers (plugins that know how to talk to an API), region, and default tags for every resource |
| `variables.tf` | Inputs: region, project name, owner, environment (validated to dev, staging or prod), versioning on or off |
| `terraform.tfvars` | The actual values for those inputs |
| `main.tf` | The resources: random suffix, bucket, versioning, encryption, public access block, one object |
| `outputs.tf` | Values printed after apply: bucket name, ARN, region, versioning status, object URI |

The bucket name gets a random suffix (`random_id`) because S3 bucket names have to be unique across every AWS account in the world.

## Prerequisites

```bash
terraform version
aws --version
aws configure
aws sts get-caller-identity
```

`aws configure` stores the access key of an IAM user (not the root account) in `~/.aws/credentials`, and Terraform's AWS provider reads it from there. `get-caller-identity` confirms which account and user the credentials belong to.

## terraform init

```bash
terraform init
```

Downloaded the `aws` (v6.67.0) and `random` (v3.9.1) providers into `.terraform/` and wrote `.terraform.lock.hcl`, which pins the exact provider versions so every run uses the same ones.

![](../image1.png)

## terraform fmt and validate

```bash
terraform fmt
terraform validate
```

`fmt` rewrites the files into the standard style. It prints the names of files it changed, and here it printed nothing because they were already formatted. `validate` checks the syntax and references without contacting AWS, and answered `Success! The configuration is valid.`

![](../image2.png)

## terraform plan

```bash
terraform plan -out=tfplan
```

A dry run. Terraform compares the code with the state (its record of what already exists) and with AWS, then lists what it would do. Here it is `Plan: 6 to add, 0 to change, 0 to destroy`. `-out=tfplan` saves the plan to a file, so that apply does exactly what I reviewed and nothing else. The screenshot is long because the plan lists every attribute of all 6 resources.

![](../image3.png)

## terraform apply

```bash
terraform apply tfplan
```

Applying a saved plan does not ask for `yes`, because the plan was already reviewed. It created the resources in dependency order and finished with `Apply complete! Resources: 6 added, 0 changed, 0 destroyed`. The random suffix is created first because the bucket name needs it, and the bucket comes before its versioning, encryption and public access settings because they all reference `aws_s3_bucket.demo.id`.

![](../image4.png)

Confirmed in AWS from the command line instead of the console. The bucket `romit-tf-s3-demo-dev-daf5fa0e` exists, it holds `hello.txt` (50 bytes), and versioning is `Enabled`:

```bash
aws s3 ls | grep romit-tf-s3-demo
aws s3 ls s3://$(terraform output -raw bucket_name)
aws s3api get-bucket-versioning --bucket $(terraform output -raw bucket_name)
```

![](../image5.png)

## terraform show and output

```bash
terraform show | head -40
terraform output
terraform output -raw bucket_name
```

`show` prints everything Terraform recorded in `terraform.tfstate` about each resource. `output` prints only the declared outputs, and `-raw` prints one value with no quotes, which is handy in scripts.

![](../image6.png)

## terraform destroy

```bash
terraform destroy -auto-approve
aws s3 ls | grep romit-tf-s3-demo
```

Deletes everything this configuration created, in reverse dependency order. `-auto-approve` skips the `yes` prompt, which is fine for a throwaway demo but not something to use on real infrastructure. `force_destroy = true` on the bucket lets it be deleted even though it still contains objects and old versions. It ended with `Destroy complete! Resources: 6 destroyed`, and the final `aws s3 ls` returned nothing. The top of the screenshot is the destroy plan, and the result is at the bottom.

![](../image7.png)

## What Not to Commit

`.gitignore` excludes `.terraform/` (downloaded plugins), the saved `tfplan` file, and `*.tfstate` (state can contain sensitive values, and in a team it belongs in a remote backend such as an S3 bucket, not in Git). The lock file `.terraform.lock.hcl` should be committed.
