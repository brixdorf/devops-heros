# IAM - Security and Identity

## What is IAM

IAM stands for Identity and Access Management. It is the AWS service that decides who can log in to an AWS account and what they are allowed to do once they are in. IAM is global, meaning it is not tied to one region, and it costs nothing extra to use.

Two words come up all the time:

- **Authentication** means proving who you are (a password, an access key, an MFA code).
- **Authorization** means deciding what you are allowed to do after AWS knows who you are.

IAM handles both. When you first create an AWS account you get a **root user**, which is the email address you signed up with. The root user can do absolutely everything, so the first thing you should learn is to stop using it for daily work.

## Users

An IAM user is an identity that represents one person or one application. A user can have:

- A password, for signing in to the AWS Management Console (the web UI).
- Access keys, which are a key ID plus a secret key used by the AWS CLI or SDKs (code libraries) to make API calls.

Access keys are long-term credentials, meaning they never expire on their own. If one leaks (for example, pushed to GitHub by accident), anyone can use it. AWS now recommends that humans sign in through IAM Identity Center or another identity provider and get short-term credentials instead of having IAM users with permanent keys.

## Groups

A group is a collection of IAM users. You attach permissions to the group and every user in it inherits them. For example, a `developers` group might get read access to logs, while an `admins` group gets wider access. Groups cannot contain other groups, and a group is not an identity on its own, so you cannot "log in as" a group.

## Roles

A role is an identity with permissions, but no password or long-term keys. Instead, someone or something **assumes** the role and receives temporary credentials that expire after a set time.

Roles are used for:

- Giving an EC2 instance or Lambda function permission to call other AWS services, without storing keys on the machine.
- Letting a user from another AWS account access yours (cross-account access).
- Letting users from an outside login system (like Google or a company directory) into AWS. This is called federation.
- CI/CD pipelines, for example GitHub Actions assuming a role through OIDC (a standard way for one system to vouch for an identity) instead of storing keys as secrets.

Every role has a **trust policy** that says who is allowed to assume it, and a **permissions policy** that says what the role can do.

## Policies

A policy is a JSON document that lists permissions. Each policy has one or more statements, and each statement has:

- `Effect`: either `Allow` or `Deny`.
- `Action`: the API calls, such as `s3:GetObject`.
- `Resource`: which resources, written as ARNs (Amazon Resource Names, the unique ID of every AWS resource).
- `Condition` (optional): extra rules like "only from this IP" or "only if MFA is used".

Here is a small policy that lets someone read objects from one bucket only:

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": ["s3:GetObject", "s3:ListBucket"],
      "Resource": [
        "arn:aws:s3:::my-app-logs",
        "arn:aws:s3:::my-app-logs/*"
      ]
    }
  ]
}
```

Policy types worth knowing:

- **AWS managed policies** are written and maintained by AWS (for example `ReadOnlyAccess`).
- **Customer managed policies** are ones you write and can reuse across users, groups and roles.
- **Inline policies** are embedded directly into a single user, group or role and are deleted with it.
- **Resource-based policies** are attached to a resource instead of an identity, like an S3 bucket policy.

## Permissions

By default, every new IAM identity has no permissions at all. Access is denied unless a policy allows it. When AWS evaluates a request, the rules are:

1. Start with an implicit deny.
2. If any policy has an explicit `Deny` that matches, the request is denied. An explicit deny always wins.
3. Otherwise, if some policy has a matching `Allow`, the request is allowed.

So if a user is in a group that allows `s3:*` but also has a policy that denies `s3:DeleteBucket`, they still cannot delete buckets.

## Least privilege

Least privilege means giving an identity only the permissions it actually needs to do its job, and nothing extra. Instead of `"Action": "*"`, you list the exact actions. Instead of `"Resource": "*"`, you list the exact ARNs.

This limits the damage if credentials are stolen or if someone makes a mistake. A practical approach is to start small, watch what fails, and add permissions as needed. IAM Access Analyzer can also look at past activity and suggest a tighter policy.

## IAM best practices

- Turn on MFA (multi-factor authentication, a second code from a phone app or hardware key) for the root user, and then lock the root user away.
- Use roles and temporary credentials instead of long-term access keys wherever possible.
- Manage human access through IAM Identity Center or federation rather than many separate IAM users.
- Assign permissions to groups or roles, not to individual users one by one.
- Rotate or delete access keys that are old or unused. The IAM credential report shows when each key was last used.
- Use conditions (source IP, MFA required, specific tags) to tighten sensitive permissions.
- Never commit access keys to Git. Use environment variables, a secrets manager or a role.

## Common use cases

- An EC2 instance role that lets a web server read files from S3 without hard-coded keys.
- A Terraform user or CI role with permission to create only the resources in your project.
- A read-only role for auditors who need to look but not change anything.
- Cross-account roles so a central "tooling" account can deploy into dev, staging and prod accounts.

A quick CLI example of creating a group and adding a user to it:

```bash
aws iam create-group --group-name developers
aws iam attach-group-policy --group-name developers \
  --policy-arn arn:aws:iam::aws:policy/ReadOnlyAccess
aws iam add-user-to-group --group-name developers --user-name romit
```
