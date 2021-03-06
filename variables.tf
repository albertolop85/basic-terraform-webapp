variable "aws_access_key" {}

variable "aws_secret_key" {}

variable "ecs_cluster_name" {}

variable "ecs_service_name" {}

variable "alb_name" {}

variable "alb_target_group_name" {}

variable "instance_role_name" {}

variable "security_group_name" {}

variable "instance_profile_name" {}

variable "aws_logs_group_name" {}

variable "task_definition_name" {}

variable "region" {
  default = "us-east-1"
}

variable vpc_id {
  default = "vpc-0d92d2d69f9568bd8"
}
