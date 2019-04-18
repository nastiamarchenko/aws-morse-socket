#
# Network Load Balancer (NLB)
#

resource "aws_lb" "main" {
  name               = "nlb-${var.name}-${var.environment}"
  load_balancer_type = "network"
  internal           = false
  subnets            = ["${aws_subnet.public.*.id}"]  
  enable_cross_zone_load_balancing = "${var.enable_cross_zone_load_balancing}"

#  subnet_mapping {
#    subnet_id     = "${aws_subnet.public.0.id}"
#    allocation_id = "${aws_eip.gw.0.id}"
#  }

#  subnet_mapping {
#    subnet_id     = "${aws_subnet.public.1.id}"
#    allocation_id = "${aws_eip.gw.1.id}" 
#  }


  tags = {
    Environment = "${var.environment}"
    Automation  = "Terraform"
  }
}

resource "aws_lb_listener" "main" {
  load_balancer_arn = "${aws_lb.main.id}"
  port              = "${var.nlb_listener_port}"
  protocol          = "TCP"

  default_action {
    target_group_arn = "${aws_lb_target_group.main.id}"
    type             = "forward"
  }
}

resource "aws_lb_target_group" "main" {
  name = "ecs-${var.name}-${var.environment}-${var.container_port}"
  port = "${var.container_port}"

  protocol    = "TCP"
  vpc_id      = "${aws_vpc.main.id}"
  target_type = "ip"

  # The amount time for the NLB to wait before changing the state of a
  # deregistering target from draining to unused. Default is 300 seconds.
  deregistration_delay = 90

  # Enable/Disable sending Proxy Protocol V2 headers
  # https://www.haproxy.org/download/1.8/doc/proxy-protocol.txt
  proxy_protocol_v2 = "${var.enable_proxy_protocol_v2}"

  # Workaround for
  # https://github.com/terraform-providers/terraform-provider-aws/issues/2746
  stickiness = []

#  health_check {
#    protocol = "${var.health_check_protocol}"
#    port     = "${var.health_check_port}"
#    path     = "${var.health_check_protocol == "HTTP" || var.health_check_protocol == "HTTPS" ? var.health_check_path : ""}"
#  }

  # Ensure the NLB exists before things start referencing this target group.
  depends_on = ["aws_lb.main"]

  tags = {
    Environment = "${var.environment}"
    Automation  = "Terraform"
  }
}



#resource "aws_proxy_protocol_policy" "morsecode"{
#  load_balancer = "${aws_lb.main.name}"
#  instance_ports = ["110","8080"]
#  depends_on =  ["aws_lb.main"]
#}
