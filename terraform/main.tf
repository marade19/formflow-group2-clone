module "networking" {
  source = "./modules/networking"

  project_name         = var.project_name
  vpc_cidr             = var.vpc_cidr
  public_subnet_1_cidr = var.public_subnet_1_cidr
  public_subnet_2_cidr = var.public_subnet_2_cidr
  availability_zone_1  = var.availability_zone_1
  availability_zone_2  = var.availability_zone_2
  tags                 = local.common_tags
}

module "security" {
  source = "./modules/security"

  project_name = var.project_name
  vpc_id       = module.networking.vpc_id
  tags         = local.common_tags
}

module "iam" {
  source = "./modules/iam"

  project_name = var.project_name
  tags         = local.common_tags
}

module "ec2" {
  source = "./modules/ec2"

  project_name  = var.project_name
  instance_type = var.instance_type

  subnet_id         = module.networking.public_subnet_1_id
  security_group_id = module.security.ec2_security_group_id

  instance_profile_name = module.iam.instance_profile_name

  tags = local.common_tags
}

# alb module
module "alb" {
  source = "./modules/alb"

  project_name = var.project_name
  vpc_id       = module.networking.vpc_id

  public_subnet_1_id = module.networking.public_subnet_1_id
  public_subnet_2_id = module.networking.public_subnet_2_id

  alb_security_group_id = module.security.alb_security_group_id
  instance_id           = module.ec2.instance_id

  tags = local.common_tags
}