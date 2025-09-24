output "azs" {
  value = data.aws_availability_zones.available.names
}

output "vpc_id" {
    value = aws_vpc.custom-vpc.id
  
}

output "subnet_id" {
    value = aws_subnet.custom-subnets.*.id
  
}