module "vpc" {
    #name = "vpc-${local.name_suffix}"
    source = "./Modules/VPC"
    vpc_cidr = var.vpc_cidr
    subnet_cidr_block = var.subnet_cidr_block
    #tags =local.tags
  
}

module "sg" {
    source = "./Modules/SG"
    vpc_id = module.vpc.vpc_id
  
}

module "ec2" {
    source = "./Modules/EC2"
    sg_id = module.sg.sg_id
    subnet_id = module.vpc.subnet_id
  
}

module "alb" {
    source = "./Modules/ALB"
    sg_id = module.sg.sg_id
    subnet_id = module.vpc.subnet_id
    vpc_id = module.vpc.vpc_id
    instace_id = module.ec2.ec2_id
    
  
}