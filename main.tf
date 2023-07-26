provider "aws" {
   region = "us-east-1"
   profile = "Student"
}


module "vpc_module" {
  source = "./vpc_module"
}

module "ebs_module" {
  source = "./ebs_module"
  vpc_id = module.vpc_module.vpc_id
  private_id = module.vpc_module.private_id
  public_id = module.vpc_module.public_id
  sg_id = module.vpc_module.sg_id
}

module "cloudfront_module" {
  source = "./cloudfront_module"
  elb_dns_name = module.ebs_module.elb_dns_name
}
