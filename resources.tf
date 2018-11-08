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
}
