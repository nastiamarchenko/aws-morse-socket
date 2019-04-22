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

variable "region1_cluster_name" {
  default     = "us-for-morse"
}

variable "region2_cluster_name" {
  default     = "eu-for-morse"
}

variable "region3_cluster_name" {
  default     = "ap-for-morse"
}

provider "aws" {
  access_key = "${var.access_key}"
  secret_key = "${var.secret_key}"
  region     = "${var.aws_region1}"
}


#variable "ecs_autoscale_role" {}

#"${aws_iam_role.iam_for_autoscale.arn}"

#variable "instance_profile" {}

#    iam_instance_profile        = "${aws_iam_instance_profile.ecs-instance-profile.id}"


module "cluster1" {
  source       = "./source"
  region       = "${var.aws_region1}"
  ecs_task_execution_role = "${aws_iam_role.iam_for_ecs_tasks.arn}"
#  instance_profile = "${aws_iam_instance_profile.ecs-instance-profile.id}"
  ecs_autoscale_role = "${aws_iam_role.iam_for_autoscale.arn}"
}


module "cluster2" {
  source       = "./source"
  region       = "${var.aws_region2}"
  ecs_task_execution_role = "${aws_iam_role.iam_for_ecs_tasks.arn}"
#  instance_profile = "${aws_iam_instance_profile.ecs-instance-profile.id}"
#  cluster_name = "${var.region2_cluster_name}"
  ecs_autoscale_role = "${aws_iam_role.iam_for_autoscale.arn}"
}


module "cluster3" {
  source       = "./source"
  region       = "${var.aws_region3}"
  ecs_task_execution_role = "${aws_iam_role.iam_for_ecs_tasks.arn}"
#  instance_profile = "${aws_iam_instance_profile.ecs-instance-profile.id}"
#  cluster_name = "${var.region3_cluster_name}"
   ecs_autoscale_role = "${aws_iam_role.iam_for_autoscale.arn}"
}


output "nlb_arn_region1" {
  description = "The ARN of the NLB-region1."
  value       = "${module.cluster1.nlb_arn}"
}

output "nlb_dns_name_region1" {
  description = "DNS name of the NLB-region1."
  value       = "${module.cluster1.nlb_dns_name}"
}

output "nlb_arn_region2" {
  description = "The ARN of the NLB-region2."
  value       = "${module.cluster2.nlb_arn}"
}

output "nlb_dns_name_region2" {
  description = "DNS name of the NLB-region2."
  value       = "${module.cluster2.nlb_dns_name}"
}

output "nlb_arn_region3" {
  description = "The ARN of the NLB-region3."
  value       = "${module.cluster3.nlb_arn}"
}

output "nlb_dns_name_region3" {
  description = "DNS name of the NLB-region3."
  value       = "${module.cluster3.nlb_dns_name}"
}

output "eip1" {
    description = "EIP-region1."
    value       = ["${module.cluster1.eip}"]
}

output "eip2" {
  description = "EIP-region2."
  value       = ["${module.cluster2.eip}"]
}

output  "eip3" {
  description = "EIP-region3."
  value       = ["${module.cluster3.eip}"]
}

