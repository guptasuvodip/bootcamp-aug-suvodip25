Deployment Plan: Deploy a 3 tier architecture in AWS using Terraform
Steps
1)Create a VPC

2)Define a CIDR block (e.g., 10.0.0.0/16).
Ensure proper IP range for public and private subnets.
Create Subnets

3)Public Subnet
Assign a CIDR block within the VPC range (e.g., 10.0.1.0/24).
Enable auto-assign public IP for instances.
Private Subnet
Assign a different CIDR block (e.g., 10.0.2.0/24).
Do not assign public IPs to instances.
Configure Internet Gateway (IGW)

4)Attach IGW to the VPC.
Create a route in the public subnet route table:
Destination: 0.0.0.0/0 → Target: Internet Gateway.
Launch EC2 Instance in Public Subnet

5)Assign a public IP.
Ensure it is reachable from the Internet (for SSH, web access, etc.).
Create NAT Gateway in Public Subnet

6)Allocate an Elastic IP (static public IP) for NAT Gateway.
Place the NAT Gateway in the public subnet.
Configure Private Subnet Route Table

7)Add a route:
Destination: 0.0.0.0/0 → Target: NAT Gateway.
This allows private EC2 instances to reach the Internet for updates without being directly accessible from the Internet.
Launch EC2 Instance in Private Subnet

8)Do not assign a public IP.
The instance can download updates via the NAT Gateway.
Instance remains isolated from inbound Internet traffic.
Testing Connectivity

9)Verify that:
Public EC2 instance can access the Internet.
Private EC2 instance can download updates but is not directly reachable from the Internet.
Optional Enhancements

10)Use NAT Gateway in multiple AZs for high availability.
Configure bastion host in public subnet if you need SSH access to private EC2.
RDS Setup

11)Generate a random password for the RDS instance
Store the RDS password in AWS Secrets Manager
Create a security group for the RDS instance
Create the RDS PostgreSQL instance
Create a DB subnet group for the RDS instance
Security Groups and Access Control

Public EC2 instance: allow inbound SSH/HTTP/HTTPS as needed.
Private EC2 instance: allow inbound traffic only from the public EC2 instance or other internal resources.
Private RDS instance: allow inbound only from private EC2 instance
