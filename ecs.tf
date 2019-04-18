resource "aws_ecs_cluster" "main" {
  name = "morse-cluster"
}


#resource "null_resource" "test_template" {
#  triggers = {
#    json = "${data.template_file.morse_app.rendered}"
#  }
#}

#data "template_file" "morse_app" {
#  template = "${file("templates/morse_app.json.tpl")}"

#  vars {
#    app_image      = "${var.app_image}"
#    fargate_cpu    = "${var.fargate_cpu}"
#    fargate_memory = "${var.fargate_memory}"
#    aws_region     = "${var.aws_region1}"
#    app_port       = "${var.app_port}"
#  }
#}




resource "aws_ecs_task_definition" "morse-socket" {
  family                   = "morse-socket"
  execution_role_arn       = "${aws_iam_role.iam_for_ecs_tasks.arn}"
  task_role_arn            = "${aws_iam_role.iam_for_ecs_tasks.arn}"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "${var.fargate_cpu}"
  memory                   = "${var.fargate_memory}" 
#  container_definitions    = "${data.template_file.morse_app.rendered}"
  container_definitions = <<DEFINITION

[
  {
    "name": "morse-socket",
    "image": "${aws_ecr_repository.morse-socket.repository_url}",
    "cpu":   10,
    "memory":512,
    "essential": true,
    "portMappings": [
      {
        "containerPort": 8080,
        "protocol":  "tcp"
      }
    ],
     "networkBindings": [
      {
          "bindIP": "0.0.0.0",
          "containerPort": 8080,
          "hostPort": 8080
       }
      ]

  }
]
DEFINITION

}

resource "aws_ecs_service" "main" {
  name            = "morse-socket"
  cluster         = "${aws_ecs_cluster.main.id}"
  task_definition = "${aws_ecs_task_definition.morse-socket.arn}"
  desired_count   = "${var.app_count}"
  launch_type     = "FARGATE"

  network_configuration {
    security_groups  = ["${aws_security_group.ecs_tasks.id}"]
    subnets          = ["${aws_subnet.private.*.id}"]
    assign_public_ip = true
  }

  load_balancer {
    target_group_arn = "${aws_lb_target_group.main.id}"
    container_name   = "morse-socket"
    container_port   = "${var.app_port}"
  }

  depends_on = [
    "aws_lb_listener.main",
  ]
}
