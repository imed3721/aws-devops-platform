resource "aws_vpc" "main" {
  cidr_block           = "10.20.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "devops-platform-vpc"
  }
}

resource "aws_subnet" "private" {
  count = 2

  vpc_id = aws_vpc.main.id

  cidr_block = count.index == 0 ? "10.20.1.0/24" : "10.20.2.0/24"

  availability_zone = data.aws_availability_zones.available.names[count.index]

  map_public_ip_on_launch = false

  tags = {
    Name = "devops-platform-private-${count.index + 1}"
    Tier = "private"
  }
}

resource "aws_security_group" "application" {
  name        = "devops-platform-application"
  description = "Security group reserved for the application"
  vpc_id      = aws_vpc.main.id

  tags = {
    Name = "devops-platform-application"
  }
}

resource "aws_security_group" "database" {
  name        = "devops-platform-database"
  description = "Database access restricted to the application security group"
  vpc_id      = aws_vpc.main.id

  ingress {
    description     = "PostgreSQL from the application security group"
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [aws_security_group.application.id]
  }

  egress {
    description = "Outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "devops-platform-database"
  }
}

resource "aws_db_subnet_group" "database" {
  name       = "devops-platform-db-subnets"
  subnet_ids = aws_subnet.private[*].id

  tags = {
    Name = "devops-platform-db-subnets"
  }
}
