# EC2 - Compute

## What is EC2

Elastic Compute Cloud rents virtual servers, called instances, billed by the second. You choose the OS, size and network.

## AMI

Amazon Machine Image, the template an instance boots from. It contains the OS and any preinstalled software.

## Instance types

The size of the instance, meaning its CPU, memory and network. For example `t3.micro` is a small general purpose type.

## Key pairs

An SSH key pair. AWS puts the public key on the instance and you keep the private key to log in.

```bash
aws ec2 create-key-pair --key-name devops-key \
  --query 'KeyMaterial' --output text > devops-key.pem
chmod 400 devops-key.pem
ssh -i devops-key.pem ec2-user@<public-ip>
```

## Security Groups

A stateful virtual firewall on the instance. It only has allow rules, and return traffic is allowed automatically.

## EBS

Elastic Block Store, network disks attached to an instance. The data survives a stop and start, and snapshots back it up.

## Public vs private IP

The private IP works only inside the VPC and stays with the instance. The public IP is reachable from the internet and changes on stop and start unless an Elastic IP is used.

## Instance lifecycle

pending, running, stopping, stopped and terminated. A stopped instance keeps its EBS disk and stops compute charges, and a terminated one is gone.

## Common use cases

Web and application servers, batch jobs, self-managed databases, and worker nodes for Kubernetes.

```bash
aws ec2 run-instances --image-id ami-0abcdef1234567890 \
  --instance-type t3.micro --key-name devops-key \
  --security-group-ids sg-0123456789abcdef0 \
  --subnet-id subnet-0123456789abcdef0 \
  --tag-specifications 'ResourceType=instance,Tags=[{Key=Name,Value=web-1}]'
```
