# DynamoDB and RDS - Databases

AWS has many database services. These two are the ones you meet first: DynamoDB for NoSQL and RDS for classic relational databases.

## DynamoDB: NoSQL

DynamoDB is a fully managed NoSQL database. "Fully managed" means there are no servers to patch or disks to size. "NoSQL" means it does not use tables with fixed columns and joins like SQL databases do. Instead it stores flexible key-value and document data, and it is built to answer simple lookups very fast at any scale.

There are two capacity modes:

- **On-demand**: you pay per read and write request, with no planning. Good for new or unpredictable apps.
- **Provisioned**: you set read and write capacity units in advance (optionally with auto scaling). Cheaper for steady, predictable traffic.

## DynamoDB: Tables, Items and Attributes

- A **table** is a collection of data, like `Orders`.
- An **item** is one record in the table, like one order. An item can be at most 400 KB.
- An **attribute** is a single field in an item, like `status` or `total`. Items in the same table do not need the same attributes. Only the key attributes are required.

## DynamoDB: Partition key and Sort key

The **primary key** uniquely identifies each item, and you choose it when you create the table.

- The **partition key** (also called hash key) is hashed by DynamoDB to decide which internal partition stores the item. A good partition key has many distinct values (like `customerId`) so traffic spreads evenly. A bad one (like `country`) creates "hot" partitions.
- The **sort key** (also called range key) is optional. Items with the same partition key are stored together, ordered by the sort key, which lets you query ranges like "all orders for this customer in 2026".

Example table design for orders:

| customerId (partition key) | sk = orderDate#orderId (sort key) | status | total |
|---|---|---|---|
| C101 | 2026-09-14#O-9001 | SHIPPED | 1299 |
| C101 | 2026-10-02#O-9042 | PENDING | 450 |
| C202 | 2026-10-05#O-9050 | SHIPPED | 89 |

```bash
aws dynamodb query --table-name Orders \
  --key-condition-expression "customerId = :c AND begins_with(sk, :y)" \
  --expression-attribute-values '{":c":{"S":"C101"},":y":{"S":"2026-"}}'
```

If you need to search by another attribute, you add a secondary index (a global secondary index can use a completely different key).

## DynamoDB: Use cases

- Terraform state locking (a `LockID` table). Note that newer Terraform versions can lock state with an S3 lockfile instead, so check which your course uses.
- User sessions, shopping carts and user profiles.
- Leaderboards, IoT sensor data and event logs with very high write rates.
- Serverless backends with Lambda and API Gateway.

## RDS: Relational database

RDS (Relational Database Service) runs SQL databases for you. A relational database stores data in tables with fixed columns, links tables with keys and joins, and supports transactions (a group of changes that either all succeed or all fail). RDS handles provisioning, OS and engine patching, backups and failover. You still design the schema and tune queries.

## RDS: Supported engines

- RDS for MySQL
- RDS for PostgreSQL
- RDS for MariaDB
- RDS for Oracle
- RDS for Microsoft SQL Server
- RDS for IBM Db2
- Amazon Aurora, an AWS-built engine compatible with MySQL or PostgreSQL. It is managed through RDS but documented separately and uses a shared, distributed storage layer instead of one disk per instance.

## RDS: DB instances

A DB instance is an isolated database environment in the cloud and the basic building block of RDS. It can hold one or more databases. You pick:

- An **instance class**, which sets CPU and memory, for example `db.t4g.micro` or `db.m7g.large`.
- **Storage**: General Purpose SSD (gp2/gp3) or Provisioned IOPS SSD (io1/io2).
- The VPC subnets it lives in, through a **DB subnet group** (a list of subnets in at least two AZs).

## RDS: Security

- Put the instance in private subnets and set "publicly accessible" to no.
- Use a security group that only allows the database port (for example 5432) from the app servers' security group.
- Turn on encryption at rest with KMS when creating the instance (it cannot be switched on later without restoring from a snapshot).
- Use SSL/TLS for connections, and store the master password in AWS Secrets Manager instead of in code or Terraform variables.
- Optionally use IAM database authentication for MariaDB, MySQL and PostgreSQL, so apps log in with short-lived tokens.

## RDS: Backups

- **Automated backups** take a daily snapshot plus transaction logs, which lets you do **point-in-time recovery** to any moment within the retention period. Retention can be 0 to 35 days (0 turns automated backups off). The console defaults to 7 days, while the API and CLI default to 1 day.
- **Manual snapshots** are taken when you ask and are kept until you delete them, even after the instance is deleted. They can be copied to other regions or shared with other accounts.

## RDS: Multi-AZ

Multi-AZ is about high availability, not performance. There are two deployment styles:

- **Multi-AZ DB instance**: one primary plus one standby in another AZ, kept in sync with synchronous replication. The standby does not serve reads. If the primary fails, RDS fails over to the standby and the DNS endpoint stays the same.
- **Multi-AZ DB cluster**: one writer plus two readable standbys spread over three AZs. Only RDS for MySQL and RDS for PostgreSQL support this.

## RDS: Read replicas

A read replica is a copy of the database that receives changes asynchronously (with a small delay) and serves read-only queries. Use them to take reporting or heavy read traffic off the primary. Replicas can be in another region for disaster recovery, and a replica can be promoted to a standalone database. They are about scaling reads, while Multi-AZ is about surviving failures.

## RDS: Use cases

- Backends for web apps that need joins, constraints and transactions (e-commerce orders, banking, user accounts).
- Moving an existing on-premises MySQL, PostgreSQL, Oracle or SQL Server database to AWS with minimal changes.
- Reporting systems, using a read replica so heavy queries do not slow down the main app.

Rule of thumb: pick DynamoDB when access patterns are simple and known in advance and you need huge scale. Pick RDS when your data is relational and you need flexible SQL queries.
