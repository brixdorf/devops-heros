# DynamoDB and RDS - Databases

## DynamoDB: NoSQL

A fully managed, serverless NoSQL key-value and document database, with fast reads at any scale and no fixed schema.

## DynamoDB: Tables, Items and Attributes

A table holds items, which are like rows. Each item is a set of attributes, which are like columns, and items in one table can have different attributes.

## DynamoDB: Partition key and Sort key

The partition key decides which partition stores an item and must be given in every query. An optional sort key orders the items inside a partition and allows range queries.

```bash
aws dynamodb query --table-name Orders \
  --key-condition-expression "customerId = :c AND begins_with(sk, :y)" \
  --expression-attribute-values '{":c":{"S":"C101"},":y":{"S":"2026-"}}'
```

## DynamoDB: Use cases

Sessions, shopping carts, user profiles, IoT and gaming data, where access is by key and traffic is high.

## RDS: Relational database

A managed service for SQL databases. AWS handles provisioning, patching, backups and failover.

## RDS: Supported engines

MySQL, PostgreSQL, MariaDB, Oracle, SQL Server and Db2, plus Aurora, which is compatible with MySQL and PostgreSQL.

## RDS: DB instances

The database server itself, with a chosen instance class and storage size, reached through an endpoint address.

## RDS: Security

It runs inside a VPC, usually in private subnets, with security groups limiting who can connect, encryption at rest with KMS, and TLS in transit.

## RDS: Backups

Automated daily backups with point-in-time recovery for up to 35 days, plus manual snapshots that are kept until deleted.

## RDS: Multi-AZ

A standby copy in another Availability Zone with automatic failover. It is for availability, not for scaling reads.

## RDS: Read replicas

Read-only copies kept up to date asynchronously, used to spread read traffic.

## RDS: Use cases

Applications that need joins and transactions, such as e-commerce orders, finance systems and CMS backends.
