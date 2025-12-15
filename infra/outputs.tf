output "vpc_id" {
  value = data.aws_vpc.main_vpc.id
}

output "subnet_id" {
  value = data.aws_subnet.public_subnet.id
}

output "ec2_public_ip" {
  value = aws_instance.app_server.public_ip
}

output "s3_bucket_name" {
  value = aws_s3_bucket.app_bucket.bucket
}

output "security_group_id" {
  value = aws_security_group.app_sg.id
}