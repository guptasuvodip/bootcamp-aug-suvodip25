// Generate a random password for the RDS instance
resource "random_password" "rds_password" {
  length  = 16
  special = false
}

// Store the RDS password in AWS Secrets Manager
resource "aws_secretsmanager_secret" "rds_password" {
  name = "${var.prefix}-rds-password"
}

resource "aws_secretsmanager_secret_version" "rds_password" {
  secret_id     = aws_secretsmanager_secret.rds_password.id
  secret_string = jsonencode({ password = random_password.rds_password.result })
}

// Create a security group for the RDS instance
resource "aws_security_group" "rds" {
  vpc_id = aws_vpc.main.id

  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = [aws_subnet.private.cidr_block]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(
    local.common_tags,
    tomap({ "Name" = "${local.prefix}-rds-sg" })
  )
}

// Create the RDS PostgreSQL instance
resource "aws_db_instance" "mysql" {
  identifier              = "${var.db_name}-mysql"
  engine                 = "mysql"
# engine_version         = "8.0.42"
  instance_class          = "db.t3.micro"
  allocated_storage       = 30
  username                = "dbadmin"
  password                = random_password.rds_password.result
  vpc_security_group_ids  = [aws_security_group.rds.id]
  db_subnet_group_name    = aws_db_subnet_group.main.name
  skip_final_snapshot     = true

  tags = merge(
    local.common_tags,
    tomap({ "Name" = "${local.prefix}-mysql" })
  )
}

# // Create a DB subnet group for the RDS instance
# resource "aws_db_subnet_group" "main" {
#   name       = "${var.prefix}-db-subnet-group"
#   subnet_ids = [aws_subnet.private.id]

#   tags = merge(
#     local.common_tags,
#     tomap({ "Name" = "${local.prefix}-db-subnet-group" })
#   )
# }


// Create a DB subnet group for the RDS instance
resource "aws_db_subnet_group" "main" {
  name       = "${var.prefix}-db-subnet-group"
  subnet_ids = [
    aws_subnet.private.id,
    aws_subnet.private_b.id
  ]
  tags = merge(
    local.common_tags,
    tomap({ "Name" = "${local.prefix}-db-subnet-group" })
  )
}

// Create a security group for the EC2 instance
resource "aws_security_group" "ec2" {
  vpc_id = aws_vpc.main.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    security_groups = [aws_security_group.rds.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(
    local.common_tags,
    tomap({ "Name" = "${local.prefix}-ec2-sg" })
  )
}