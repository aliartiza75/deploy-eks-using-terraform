terraform {
  required_version = ">= 0.12.7"
}

# Instead of defining variables in variables.tf, variables can be defined in the same file
# using the local construct 
locals {
  vpc_id = "vpc-ba13ddd1"
  region = "us-east-2"
  cluster_name = "eks-cluster"
  subnets = ["subnet-5b98b421", "subnet-5d950211", "subnet-ed679186"]
  # logs has been disabled due to cost
  # cluster_enabled_log_types = ["api", "audit", "authenticator", "controllerManager", "scheduler"]
}

provider "aws" {
  region  = local.region
}

module "eks-cluster" {
  source       = "terraform-aws-modules/eks/aws"
  cluster_name = local.cluster_name
  subnets = local.subnets
  vpc_id  = local.vpc_id
  

  worker_groups = [
    {
      spot_price = "0.20"
      asg_desired_capacity = 3
      asg_max_size = 4
      asg_min_size = 1
      instance_type = "m4.large"
      name = "worker-group"
      additional_userdata = "Public worker group configurations"
      tags = [{
          key                 = "worker-group-tag"
          value               = "worker-group-1"
          propagate_at_launch = true
      }]
    }
  ]

  map_users = [
      {
        "userarn" = "arn:aws:iam::100949062396:user/irtiza"
        "username" = "irtiza"
        "groups"    = ["system:masters"]
      }
    ]
  # disabled due to cost 
  # cluster_enabled_log_types = local.cluster_enabled_log_types
  tags = {
    environment = "dev-env"
  }
}