data "aws_vpc" "default" {
  default = true
}

data "aws_subnet_ids" "default" {
  vpc_id = data.aws_vpc.default.id
}

locals {
  public_subnet_id = element(data.aws_subnet_ids.default.ids, 0)
}

resource "aws_security_group" "web_sg" {
  name        = "travelmemory-web-sg"
  description = "Allow HTTP/HTTPS/SSH"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "db_sg" {
  name        = "travelmemory-db-sg"
  description = "MongoDB security group"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    description     = "MongoDB access from web"
    from_port       = 27017
    to_port         = 27017
    protocol        = "tcp"
    security_groups = [aws_security_group.web_sg.id]
  }

  ingress {
    description = "SSH access"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "web" {
  ami                    = var.ami
  instance_type          = var.instance_type_web
  subnet_id              = local.public_subnet_id
  key_name               = var.key_name
  vpc_security_group_ids = [aws_security_group.web_sg.id]

  tags = {
    Name = "travelmemory-web"
  }
}

resource "aws_instance" "db" {
  ami                    = var.ami
  instance_type          = var.instance_type_db
  subnet_id              = local.public_subnet_id
  key_name               = var.key_name
  vpc_security_group_ids = [aws_security_group.db_sg.id]

  tags = {
    Name = "travelmemory-db"
  }
}
