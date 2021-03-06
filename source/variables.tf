

variable "health_check_protocol" {
  description = "The protocol that will be used for health checks.  Options are: TCP, HTTP, HTTPS"
  default     = "TCP"
  type        = "string"
}

variable "container_port" {
  description = "The port on which the container will receive traffic."
  default     = 8080
  type        = "string"
}

variable "health_check_port" {
  description = "The port on which the container will receive health checks."
  default     = 8080
  type        = "string"
}

variable "app_port" {
  description = "Port exposed by the docker image to redirect traffic to"
  default     = 8080
}

variable "health_check_path" {
  description = "When using a HTTP(S) health check, the destination for the health check requests to the container."
  type        = "string"
  default     = "/"
}

variable "environment" {
  description = "Environment tag, e.g prod."
  type        = "string"
  default     = "prod"
}

variable "enable_proxy_protocol_v2" {
  description = "Boolean to enable / disable support for proxy protocol v2."
  default     = "true"
  type        = "string"
}

variable "enable_cross_zone_load_balancing" {
  description = "If true, cross-zone load balancing of the load balancer will be enabled."
  default     = true
  type        = "string"
}

variable "name" {
  description = "The service name."
  type        = "string"
  default     = "app"
}


variable "nlb_listener_port" {
  description = "The port on which the NLB will receive traffic."
  default     = "110"
  type        = "string"
}


variable "nlb_vpc_id" {
  description = "VPC ID to be used by the NLB."
  type        = "string"
  default     = "aws_vpc.main.id"
}



variable "az_count" {
  description = "Number of AZs to cover in a given region"
  default     = "2"
}

variable "app_image" {
  description = "Docker image to run in the ECS cluster"
  default     = "morse-socket:latest"
}


variable "app_count" {
  description = "Number of docker containers to run"
  default     = 3
}


variable "fargate_cpu" {
  description = "Fargate instance CPU units to provision (1 vCPU = 1024 CPU units)"
  default     = "1024"
}

variable "fargate_memory" {
  description = "Fargate instance memory to provision (in MiB)"
  default     = "2048"
}
