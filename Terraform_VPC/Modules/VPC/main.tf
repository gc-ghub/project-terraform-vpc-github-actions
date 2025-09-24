
#vpc
resource "aws_vpc" "custom-vpc" {
    cidr_block = var.vpc_cidr
    instance_tenancy = "default"
    tags = local.tags
}




#subnets
resource "aws_subnet" "custom-subnets" {
    count = length(var.subnet_cidr_block)
  vpc_id     = aws_vpc.custom-vpc.id
  cidr_block = var.subnet_cidr_block[count.index]
  availability_zone = data.aws_availability_zones.available.names[count.index]
  map_public_ip_on_launch = true
  tags = local.tags
}




#IG
resource "aws_internet_gateway" "custom-gw" {
  vpc_id = aws_vpc.custom-vpc.id
  tags = local.tags

}



#RT
resource "aws_route_table" "custom-rt" {
  vpc_id = aws_vpc.custom-vpc.id
  tags = local.tags

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.custom-gw.id
  }
}




#RTA
resource "aws_route_table_association" "custom-rta" {
    count = length(var.subnet_cidr_block)
  subnet_id      = aws_subnet.custom-subnets[count.index].id
  route_table_id = aws_route_table.custom-rt.id
}


