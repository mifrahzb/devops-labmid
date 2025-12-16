# Use existing VPC
data "aws_vpc" "main_vpc" {
  default = true
}

# Use existing subnet
data "aws_subnet" "public_subnet" {
  vpc_id            = data.aws_vpc.main_vpc.id
  default_for_az    = true
  availability_zone = "us-east-1a"
}

# Use existing Internet Gateway
data "aws_internet_gateway" "default" {
  filter {
    name   = "attachment.vpc-id"
    values = [data.aws_vpc. main_vpc.id]
  }
}

# Security Group
resource "aws_security_group" "app_sg" {
  name   = "devops-app-sg"
  vpc_id = data.aws_vpc.main_vpc.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "devops-sg"
  }
}

# EC2 Instance
resource "aws_instance" "app_server" {
  ami                    = "ami-0c2b8ca1dad447f8a"
  instance_type          = "t3.micro"
  subnet_id              = data. aws_subnet.public_subnet. id
  vpc_security_group_ids = [aws_security_group.app_sg.id]

  tags = {
    Name = "devops-ec2"
  }
}

# Random ID for S3 bucket
resource "random_id" "bucket_id" {
  byte_length = 4
}

# S3 Bucket
resource "aws_s3_bucket" "app_bucket" {
  bucket = "devops-final-${random_id. bucket_id.hex}"
  
  tags = {
    Name = "devops-bucket"
  }
}