### Resources for deploying a web application ###

provider "aws" {
  access_key = "${var.aws_access_key}"
  secret_key = "${var.aws_secret_key}"
  region     = "${var.region}"
}

resource "aws_ecs_cluster" "webapp_cluster" {
  name = "${var.ecs_cluster_name}"
}

resource "aws_ecs_task_definition" "webapp_task_def" {
  family = "webapp-task-definition"
  container_definitions = "${file("task-definitions/webapp.json")}"
}

resource "aws_iam_role" "webapp_instance_role" {
  name = "${var.instance_role_name}"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_instance_profile" "webapp_instance_profile" {
  name = "${var.instance_profile_name}"
  role = "${aws_iam_role.webapp_instance_role.name}"
}

resource "aws_alb" "webapp_alb" {
  name = "${var.alb_name}"
  subnets = ["${data.aws_subnet_ids.webapp_subnets.ids}"]
}

data "aws_subnet_ids" "webapp_subnets" {
  vpc_id = "${var.vpc_id}"
}

resource "aws_alb_target_group" "webapp_lb_target_group" {
  name = "${var.alb_target_group_name}"
  port = 80
  protocol = "HTTP"
  vpc_id = "${var.vpc_id}"

  health_check {
    interval = 30
    protocol = "HTTP"
    healthy_threshold = 5
    unhealthy_threshold = 5
  }

  depends_on = [
    "aws_alb.webapp_alb"
  ]
}

resource "aws_lb_listener" "webapp_lb_listener" {
  load_balancer_arn = "${aws_alb.webapp_alb.arn}"
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = "${aws_alb_target_group.webapp_lb_target_group.arn}"
  }
}

resource "aws_ecs_service" "webapp_service" {
  name = "${var.ecs_service_name}"
  cluster = "${aws_ecs_cluster.webapp_cluster.id}"
  task_definition = "${aws_ecs_task_definition.webapp_task_def.arn}"
  desired_count = 1
  #iam_role = "${aws_iam_role.webapp_instance_role.arn}"
  depends_on = [
    "aws_iam_role_policy_attachment.AmazonEC2ContainerServiceforEC2Role",
    "aws_alb_target_group.webapp_lb_target_group"
  ]

  load_balancer {
    target_group_arn = "${aws_alb_target_group.webapp_lb_target_group.arn}"
    container_name =  "webapp"
    container_port = "8090"
  }
}

resource "aws_instance" "webapp_instance" {
  ami = "ami-07eb698ce660402d2"
  instance_type = "t2.micro"
  iam_instance_profile = "${aws_iam_instance_profile.webapp_instance_profile.name}"
  user_data = <<EOF
  #!/bin/bash
  # This script implements initial configuration via the
  # AWS user_data field

  # Set ECS cluster name
  echo ECS_CLUSTER="${aws_ecs_cluster.webapp_cluster.name}" >> /etc/ecs/ecs.config

EOF
}

resource "aws_iam_role_policy_attachment" "AmazonEC2ContainerServiceforEC2Role" {
  role = "${aws_iam_role.webapp_instance_role.name}"
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
}

resource "aws_security_group" "webapp_security_group" {
  vpc_id = "${var.vpc_id}"
  name = "${var.security_group_name}"
  description = "Allow HTTP traffic from Internet"

  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_cloudwatch_log_group" "webapp_log_group" {
  name = "webapp-logs"
}
