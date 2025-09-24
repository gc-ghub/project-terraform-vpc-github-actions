output "ec2_id" {
    value = aws_instance.web-server.*.id
  
}
