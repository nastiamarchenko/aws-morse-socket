resource "aws_ecs_cluster" "main" {
  name = "morse-cluster"
}



#variable "ecs_autoscale_role" {}


variable "ecs_task_execution_role" {}


#"${aws_iam_role.iam_for_ecs_tasks.arn}"

#"${aws_iam_role.iam_for_autoscale.arn}"



resource "aws_ecs_task_definition" "morse-socket" {
  family                   = "morse-socket"
  execution_role_arn       = "${var.ecs_task_execution_role}"
  task_role_arn            = "${var.ecs_task_execution_role}"
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
