output "dns_name" {
  description = "DNS for accessing to the webapp"
  value = "${aws_alb.webapp_alb.dns_name}"
}
