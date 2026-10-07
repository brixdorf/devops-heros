# S3 - Storage

## What is S3

Simple Storage Service stores files as objects, with practically unlimited capacity and very high durability.

## Buckets

A container for objects, with a globally unique name, created in one region.

```bash
aws s3 mb s3://romit-devops-demo-2026 --region ap-south-1
aws s3 cp index.html s3://romit-devops-demo-2026/site/index.html
aws s3 ls s3://romit-devops-demo-2026/site/
```

## Objects

A file plus its metadata, identified by a key. One object can be up to 5 TB.

## Storage classes

Price tiers by access pattern: Standard for frequent access, Standard-IA and One Zone-IA for rare access, the Glacier classes for archives, and Intelligent-Tiering to move objects automatically.

## Versioning

Keeps every version of an object, so an overwrite or a delete can be undone.

```bash
aws s3api put-bucket-versioning --bucket romit-devops-demo-2026 \
  --versioning-configuration Status=Enabled
```

## Lifecycle policies

Rules that move objects to cheaper classes or delete them after a number of days.

## Encryption

Objects are encrypted at rest by default with SSE-S3, and SSE-KMS is the option for your own keys. HTTPS protects data in transit.

## Bucket policies

A JSON policy on the bucket that says who can do what with it, for example denying any request that is not over HTTPS.

## Common use cases

Backups, logs, static website files, data lakes, and Terraform remote state.
