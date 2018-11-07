### Resources for deploying a web application ###

resource "aws_ecs_cluster" "webapp_cluster" {
  name = "${var.ecs_cluster_name}"
}

resource "aws_ecs_service" "webapp_service" {
  name = "${var.ecs_service_name}"
  cluster = "${aws_ecs_cluster.webapp_cluster.id}"
}
