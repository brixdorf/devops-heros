# VPC - Networking

## What is VPC

Virtual Private Cloud, your own isolated network inside AWS where you control IP ranges, subnets, routing and firewalls.

## CIDR

The IP range of a network, written like `10.0.0.0/16`. The number after the slash is how many bits are fixed, so a /16 has about 65,000 addresses.

## Subnets

A slice of the VPC range that lives in one Availability Zone. Resources are launched into subnets.

## Route tables

Rules that say where traffic from a subnet goes. A `0.0.0.0/0` route to an internet gateway is what makes a subnet public.

## Internet Gateway

Connects the VPC to the internet in both directions, for resources that have a public IP.

## NAT Gateway

Lets instances in private subnets reach the internet for things like updates, while blocking connections coming in. It sits in a public subnet and is billed per hour.

## Security Groups

A stateful firewall at the instance level, with allow rules only.

## Network ACLs

A stateless firewall at the subnet level, with numbered allow and deny rules, so return traffic needs its own rule.

## Public vs private subnet

A public subnet routes `0.0.0.0/0` to an internet gateway and a private subnet does not. Web servers go in public subnets and databases in private ones.
