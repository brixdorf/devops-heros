# VPC - Networking

## What is VPC

A VPC (Virtual Private Cloud) is your own private, isolated network inside an AWS region. You choose its IP address range, split it into subnets, and control how traffic flows in and out. Almost every other resource, like EC2 instances, RDS databases and load balancers, lives inside a VPC.

Every region comes with a **default VPC** so you can launch things quickly, but for real projects (and in Terraform) you normally build a custom one so you understand and control every piece.

## CIDR

CIDR (Classless Inter-Domain Routing) is the notation used to describe a range of IP addresses, like `10.0.0.0/16`. The number after the slash says how many bits at the start are fixed. The rest are free for hosts.

- `/16` fixes 16 bits, leaving 16 bits, so 2^16 = 65,536 addresses.
- `/24` fixes 24 bits, leaving 8 bits, so 2^8 = 256 addresses.
- A smaller number after the slash means a bigger range.

A VPC's IPv4 block must be between `/16` and `/28`. It is best to use private ranges from RFC 1918 (`10.0.0.0/8`, `172.16.0.0/12`, `192.168.0.0/16`) and avoid overlapping with other VPCs or your office network, otherwise you cannot connect them later.

Example plan for a `10.0.0.0/16` VPC:

| Subnet | CIDR | Addresses | Usable in AWS |
|---|---|---|---|
| public-a | 10.0.1.0/24 | 256 | 251 |
| public-b | 10.0.2.0/24 | 256 | 251 |
| private-a | 10.0.11.0/24 | 256 | 251 |
| private-b | 10.0.12.0/24 | 256 | 251 |

Why 251? AWS reserves 5 addresses in every subnet. For `10.0.1.0/24` these are `.0` (network address), `.1` (VPC router), `.2` (DNS server), `.3` (reserved for future use) and `.255` (broadcast, which VPCs do not support).

## Subnets

A subnet is a slice of the VPC's CIDR range, and each subnet lives in exactly one Availability Zone (AZ). To make an app highly available, you create matching subnets in at least two AZs, so if one data center has trouble the other keeps running.

Subnet sizes must also be between `/16` and `/28`, and subnets in the same VPC cannot overlap.

## Route tables

A route table is a list of rules that tells traffic where to go based on the destination IP. Each subnet is associated with one route table. Every route table has a built-in `local` route that lets all subnets in the VPC talk to each other.

```
Public route table
Destination     Target
10.0.0.0/16     local
0.0.0.0/0       igw-0abc123      (internet gateway)

Private route table
Destination     Target
10.0.0.0/16     local
0.0.0.0/0       nat-0def456      (NAT gateway)
```

`0.0.0.0/0` means "any address not matched by a more specific route", which is effectively the internet.

## Internet Gateway

An Internet Gateway (IGW) is the door between your VPC and the public internet. It is attached to the VPC (one per VPC) and is highly available by design, so you do not manage or scale it. For an instance to be reachable from the internet it needs three things: a route to the IGW, a public IP address, and security rules that allow the traffic.

## NAT Gateway

A NAT Gateway (Network Address Translation) lets instances in private subnets start connections out to the internet, for example to download updates or call an external API, while blocking anyone on the internet from starting a connection in.

- The classic **zonal** NAT gateway sits in a public subnet in one AZ and uses an Elastic IP. For high availability you create one per AZ.
- Since November 2025 there is also a **regional** NAT gateway, which spans AZs automatically and does not need a public subnet.
- NAT gateways are billed per hour plus per GB processed, so they are often the surprise cost in student accounts. Delete them when you finish a lab.

## Security Groups

A security group is a firewall at the instance (network interface) level. It only has allow rules and is **stateful**, which means return traffic for an allowed connection is automatically let back through. A nice trick is to reference another security group as the source, for example "allow port 5432 only from the app-server security group", instead of using IP ranges.

## Network ACLs

A Network ACL (Access Control List) is a firewall at the subnet level. Differences from security groups:

| | Security Group | Network ACL |
|---|---|---|
| Applies to | Instance / network interface | Whole subnet |
| Rules | Allow only | Allow and deny |
| State | Stateful | Stateless (return traffic needs its own rule) |
| Rule order | All rules checked together | Lowest rule number first, first match wins |

The default NACL allows everything in and out. Because NACLs are stateless, if you lock them down you must allow ephemeral ports (1024 to 65535) for reply traffic. Most teams leave NACLs open and do the real filtering with security groups, using NACLs only to block specific bad IP ranges.

## Public vs private subnet

AWS does not have a "public" checkbox on a subnet. The difference comes from the route table:

- A **public subnet** has a route to an Internet Gateway. Load balancers and bastion hosts go here.
- A **private subnet** has no route to an IGW. App servers and databases go here, and they reach the internet (outbound only) through a NAT gateway.

A typical three-tier layout is: load balancer in public subnets, app servers in private subnets, and the database in private subnets with a security group that only accepts traffic from the app servers.
