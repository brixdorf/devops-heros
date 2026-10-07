# S3 - Storage

## What is S3

S3 stands for Simple Storage Service. It is object storage, which means you store whole files (called objects) and get them back by name over HTTPS. It is not a disk you mount and it is not a database. S3 is designed for 99.999999999% (eleven nines) durability, and you only pay for what you store and the requests you make.

In Terraform projects, S3 is also the most common place to keep the remote state file.

## Buckets

A bucket is a container for objects. Key facts:

- Bucket names must be globally unique across all AWS accounts, lowercase, and between 3 and 63 characters.
- A bucket is created in one region, and your data stays in that region unless you copy it out.
- New buckets block public access by default, and ACLs (the old per-object access control lists) are disabled by default through the "Bucket owner enforced" setting. Access is controlled with IAM and bucket policies instead.

```bash
aws s3 mb s3://romit-devops-demo-2026 --region ap-south-1
aws s3 cp index.html s3://romit-devops-demo-2026/site/index.html
aws s3 ls s3://romit-devops-demo-2026/site/
```

## Objects

An object is a file plus its metadata (information about the file, like content type). Each object is identified by a **key**, which is its full name inside the bucket, for example `site/index.html`.

S3 has no real folders. The "folders" you see in the console are just key prefixes separated by `/`. A single object can be up to 50 TB (AWS raised the limit from 5 TB in December 2025), and uploads larger than 100 MB should use multipart upload, which splits the file into parts sent in parallel.

## Storage classes

A storage class decides how an object is stored and priced. Cheaper classes usually mean higher retrieval fees or slower access. The current classes are:

| Class | Good for | Min. storage duration |
|---|---|---|
| S3 Standard | Frequently accessed data (the default) | None |
| S3 Intelligent-Tiering | Unknown or changing access patterns, moves data between tiers for you | None |
| S3 Express One Zone | Very low latency (single-digit ms), stored in one AZ | None |
| S3 Standard-IA | Infrequent access, still millisecond retrieval | 30 days |
| S3 One Zone-IA | Infrequent access, data you can recreate, one AZ only | 30 days |
| S3 Glacier Instant Retrieval | Archives read about once a quarter, millisecond access | 90 days |
| S3 Glacier Flexible Retrieval | Archives read about once a year, minutes to hours to restore | 90 days |
| S3 Glacier Deep Archive | Long-term archives, hours to restore, cheapest | 180 days |

Reduced Redundancy Storage still exists in the API, but AWS recommends against it because S3 Standard is cheaper. "IA" means infrequent access, and "minimum storage duration" means you are billed for at least that long even if you delete the object earlier.

## Versioning

Versioning keeps every version of an object when it is overwritten or deleted. Each version gets a version ID. A delete only adds a "delete marker" on top, so the old data can be brought back.

- Once turned on, versioning can be suspended but never fully turned off.
- Old versions still cost money, so pair versioning with a lifecycle rule.
- Always enable it on a bucket that holds Terraform state, so a broken state file can be rolled back.

```bash
aws s3api put-bucket-versioning --bucket romit-devops-demo-2026 \
  --versioning-configuration Status=Enabled
```

## Lifecycle policies

A lifecycle policy is a set of rules that automatically move or delete objects as they age. For example: move logs to Standard-IA after 30 days, to Glacier Flexible Retrieval after 90 days, and delete them after 365 days. Rules can also delete old non-current versions and clean up incomplete multipart uploads.

```json
{
  "Rules": [{
    "ID": "archive-logs",
    "Filter": { "Prefix": "logs/" },
    "Status": "Enabled",
    "Transitions": [
      { "Days": 30, "StorageClass": "STANDARD_IA" },
      { "Days": 90, "StorageClass": "GLACIER" }
    ],
    "Expiration": { "Days": 365 }
  }]
}
```

## Encryption

Since January 5, 2023, every new object uploaded to S3 is encrypted at rest automatically with SSE-S3 (server-side encryption with keys that S3 manages, using AES-256). It is free and cannot be turned off for new uploads. Your options are:

- **SSE-S3**: the default, AWS manages everything.
- **SSE-KMS**: keys stored in AWS KMS (Key Management Service), which gives you key policies and an audit trail in CloudTrail. S3 Bucket Keys reduce the KMS request cost.
- **DSSE-KMS**: two layers of KMS encryption, for strict compliance rules.
- **SSE-C**: you send your own key with every request. Starting April 2026, AWS began disabling SSE-C by default on new general purpose buckets (and on existing buckets in accounts that never used it).

For data in transit, use HTTPS. A bucket policy can deny any request where `aws:SecureTransport` is false.

## Bucket policies

A bucket policy is a resource-based JSON policy attached to the bucket. It can grant access to other accounts, roles or services, or enforce rules for everyone. This one denies any non-HTTPS request:

```json
{
  "Version": "2012-10-17",
  "Statement": [{
    "Sid": "DenyInsecureTransport",
    "Effect": "Deny",
    "Principal": "*",
    "Action": "s3:*",
    "Resource": [
      "arn:aws:s3:::romit-devops-demo-2026",
      "arn:aws:s3:::romit-devops-demo-2026/*"
    ],
    "Condition": { "Bool": { "aws:SecureTransport": "false" } }
  }]
}
```

## Common use cases

- Terraform remote state (with versioning and encryption on).
- Static website hosting, usually behind CloudFront (the AWS CDN).
- Storing build artifacts, Docker layer caches and application logs.
- Backups and long-term archives using Glacier classes.
- Data lakes, where analytics tools like Athena query files directly in S3.
