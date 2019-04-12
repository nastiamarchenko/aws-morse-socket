variable "access_key" {}
variable "secret_key" {}

variable "aws_region1" {
  default     = "us-east-1"
}

variable "aws_region2" {
  default     = "eu-west-1"
}

variable "aws_region3" {
  default     = "ap-southeast-1"
}


variable "az_count" {
  description = "Number of AZs to cover in a given region"
  default     = "2"
}

variable "app_image" {
  description = "Docker image to run in the ECS cluster"
  default     = "app/morse-code:latest"
}

variable "app_port" {
  description = "Port exposed by the docker image to redirect traffic to"
  default     = 5000
}

variable "app_count" {
  description = "Number of docker containers to run"
  default     = 3
}

variable "ecs_autoscale_role" {
  description = "Role arn for the ecsAutocaleRole"
  default     = "${aws_iam_role.iam_for_autoscale.arn}"
}


variable "ecs_task_execution_role" {
  description = "Role arn for the ecsTaskExecutionRole"
  default     = "${aws_iam_role.iam_for_ecs_tasks.arn}"
}

variable "health_check_path" {
  default = "/"
}

variable "fargate_cpu" {
  description = "Fargate instance CPU units to provision (1 vCPU = 1024 CPU units)"
  default     = "1024"
}

variable "fargate_memory" {
  description = "Fargate instance memory to provision (in MiB)"
  default     = "2048"
}
