data "aws_route53_zone" "morse" {
  name         = "amarchen.link."
}

resource "aws_route53_record" "morse" {
  zone_id = "${data.aws_route53_zone.morse.zone_id}"
  name    = "morse.amarchen.link"
  type    = "A"
  ttl     = "300"
  records =  [ ["${module.cluster1.eip}"], ["${module.cluster2.eip}"], ["${module.cluster3.eip}"]]
  latency_routing_policy {
    region = "us-west-1"
  }
  set_identifier  = "morse-us-west-1"

}
