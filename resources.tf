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

resource "aws_ecs_service" "webapp_service" {
  name = "${var.ecs_service_name}"
  cluster = "${aws_ecs_cluster.webapp_cluster.id}"
  task_definition = "${aws_ecs_task_definition.webapp_task_def.arn}"
  desired_count = 1
}

resource "aws_instance" "webapp_instance" {
  ami = "ami-07eb698ce660402d2"
  instance_type = "t2.micro"
  user_data = <<EOF
  #!/bin/bash
  # This script implements initial configuration via the
  # AWS user_data field

  # Set ECS cluster name
  echo ECS_CLUSTER="${var.ecs_cluster_name}" >> /etc/ecs/ecs.config
  EOF
}
