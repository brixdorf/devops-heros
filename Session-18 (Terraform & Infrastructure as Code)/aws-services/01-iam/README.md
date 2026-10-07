# IAM - Security and Identity

## What is IAM

Identity and Access Management controls who can sign in to an AWS account and what they are allowed to do. It is a global service and it is free.

## Users

An identity for one person or application, with a password for the console or access keys for the CLI.

## Groups

A collection of users. Permissions attached to the group apply to every member.

## Roles

An identity with permissions but no long-term credentials. A user or a service such as EC2 assumes it and gets temporary credentials.

## Policies

JSON documents that list allowed or denied actions on resources. They are attached to users, groups or roles.

## Permissions

What an identity can actually do once all its policies are evaluated. Everything is denied by default, and an explicit deny always wins.

## Least privilege

Give only the permissions needed for the task and nothing more, so a leaked key or a mistake does less damage.

## IAM best practices

Do not use the root user for daily work, turn on MFA, prefer roles over long-lived keys, grant permissions through groups, and remove unused credentials.

## Common use cases

Giving a team access through groups, letting an EC2 instance read S3 through a role, and giving a CI pipeline limited deploy rights.

```bash
aws iam create-group --group-name developers
aws iam attach-group-policy --group-name developers \
  --policy-arn arn:aws:iam::aws:policy/ReadOnlyAccess
aws iam add-user-to-group --group-name developers --user-name romit
```
