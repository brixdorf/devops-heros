# EC2 - Compute

## What is EC2

EC2 stands for Elastic Compute Cloud. It lets you rent virtual machines (called **instances**) in AWS data centers. "Elastic" means you can start more machines when you need them and stop them when you do not, paying for what you use, usually billed per second for Linux.

Each instance runs in one **Availability Zone** (AZ), which is a separate data center (or group of data centers) inside a region such as `us-east-1`.

## AMI

An AMI (Amazon Machine Image) is the template an instance boots from. It contains the operating system and any software baked in. Examples are Amazon Linux 2023, Ubuntu, or Windows Server.

- AWS and vendors publish public AMIs.
- You can create your own AMI from a configured instance, so every new server starts with your app already installed.
- AMI IDs are different in every region, which is why Terraform code often looks up the latest AMI with a data source instead of hard-coding the ID.

## Instance types

The instance type decides how much CPU, memory, storage and network speed the machine gets. The name follows a pattern, for example `t3.micro` or `m7g.large`:

- The first letter is the **family**: `t` (burstable, cheap, for light workloads), `m` (general purpose), `c` (compute optimized), `r` (memory optimized), `g` or `p` (GPU).
- The number is the **generation**. Higher is newer.
- Extra letters describe options, such as `g` for AWS Graviton (ARM) processors.
- The part after the dot is the **size**: `nano`, `micro`, `small`, `medium`, `large`, `xlarge` and so on.

Burstable `t` instances earn CPU credits while idle and spend them when busy, which fits small websites or test servers.

## Key pairs

A key pair is a public key and a private key used to log in over SSH (the secure remote shell protocol). AWS stores the public key and puts it on the instance at launch. You keep the private key file (`.pem`) and never share it.

```bash
aws ec2 create-key-pair --key-name devops-key \
  --query 'KeyMaterial' --output text > devops-key.pem
chmod 400 devops-key.pem
ssh -i devops-key.pem ec2-user@<public-ip>
```

If you lose the private key, AWS cannot give it back. Many teams now use AWS Systems Manager Session Manager instead, which opens a shell without opening port 22 at all.

## Security Groups

A security group is a virtual firewall attached to an instance's network interface. It has inbound rules (what traffic can come in) and outbound rules (what can go out).

- Rules can only **allow** traffic. There is no deny rule.
- Security groups are **stateful**. If a request is allowed in, the reply is automatically allowed out.
- By default a new security group allows all outbound traffic and no inbound traffic.

Typical web server rules: allow TCP 80 and 443 from `0.0.0.0/0` (anywhere), and allow TCP 22 only from your own IP, never from everywhere.

## EBS

EBS (Elastic Block Store) provides network-attached disks, called volumes, for EC2. They behave like a hard drive plugged into the instance. An EBS volume lives in one AZ and can only attach to instances in that same AZ.

- **gp3** is the current general purpose SSD type. It gives a baseline of 3,000 IOPS (input/output operations per second) and 125 MiB/s throughput at any size, and you can provision up to 80,000 IOPS and 2,000 MiB/s for extra cost. Volumes range from 1 GiB to 64 TiB.
- **io2** is for databases that need very high, consistent IOPS.
- **st1/sc1** are cheaper HDD types for large sequential reads.
- **Snapshots** are point-in-time backups of a volume, stored in S3 behind the scenes.

Some instance types also have **instance store**, which is a local disk that is wiped when the instance stops. Do not keep anything important there.

## Public vs private IP

- A **private IP** comes from your subnet's range (for example `10.0.1.25`). It is used for traffic inside the VPC and stays the same for the life of the instance.
- A **public IP** is reachable from the internet. An auto-assigned public IP changes every time you stop and start the instance.
- An **Elastic IP** is a static public IPv4 address that you own until you release it, so it survives stop and start.

Since February 1, 2024, AWS charges $0.005 per hour for every public IPv4 address, whether it is attached to a running instance or sitting idle. That is roughly $3.60 a month per address, so release Elastic IPs you are not using.

## Instance lifecycle

1. **pending**: the instance is booting.
2. **running**: it is up and you are billed for compute.
3. **stopping / stopped**: the machine is shut down. You are not billed for compute, but you still pay for attached EBS volumes and any Elastic IPs.
4. **rebooting**: a restart. Same host, same IPs.
5. **shutting-down / terminated**: the instance is deleted. By default the root EBS volume is deleted too.

Stopping and starting usually moves the instance to new hardware, which is why the auto-assigned public IP changes. Termination protection can be turned on to stop accidental deletes.

## Common use cases

- Hosting web servers and APIs, often behind a load balancer with an Auto Scaling group (which adds or removes instances based on load).
- Running Jenkins, GitLab runners or other CI build agents.
- Self-managed databases or apps that need full OS control.
- Batch jobs on Spot Instances, which use spare capacity at a big discount but can be taken back by AWS with a two-minute warning.

A simple launch from the CLI:

```bash
aws ec2 run-instances --image-id ami-0abcdef1234567890 \
  --instance-type t3.micro --key-name devops-key \
  --security-group-ids sg-0123456789abcdef0 \
  --subnet-id subnet-0123456789abcdef0 \
  --tag-specifications 'ResourceType=instance,Tags=[{Key=Name,Value=web-1}]'
```

Note on cost: accounts created on or after July 15, 2025 get the new AWS Free Tier, which gives up to $200 in credits and a free plan that lasts 6 months or until the credits run out. Always check the current Free Tier page before leaving instances running.
