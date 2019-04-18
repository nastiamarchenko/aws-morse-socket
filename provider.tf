provider "aws" {
  access_key = "${var.access_key}"
  secret_key = "${var.secret_key}"
  region     = "${var.aws_region1}"
}

#resource "aws_iam_user_policy" "terraform" {
#  name = "terraform"
#  user = "terraform"
#  policy = <<EOF
#{
#  "Version": "2012-10-17",
#  "Statement": {
#    "Effect": "Allow",
#    "Action": "iam:CreateUser",
#    "Resource": "arn:aws:iam::*:user/terraform"
#  }
#}
#EOF
#}


resource "aws_iam_role" "iam_for_autoscale" {
  name = "iam_for_autoscale"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "autoscaling.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_role" "iam_for_ecs_tasks" {
  name = "iam_for_ecs_tasks"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": ["ecs.amazonaws.com", "ecs-tasks.amazonaws.com"]
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}


#resource "aws_iam_role" "ecs_instance" {
#  name = "ecs-instance-role"
#
#  assume_role_policy = <<EOF
#{
#  "Version": "2012-10-17",
#  "Statement": [
#    {
#      "Sid": "",
#      "Effect": "Allow",
#      "Principal": {
#        "Service": "ec2.amazonaws.com"
#      },
#      "Action": "sts:AssumeRole"
#    }
#  ]
#}
#EOF
#}

#resource "aws_iam_instance_profile" "ecs_instance" {
#  name = "ecs-instance-profile"
#  role = "${aws_iam_role.ecs_instance.name}"
#}

data "template_file" "ecs_instance_profile" {
  template = "${file("templates/ecs-instance-profile-policy.json")}"

#  vars {
#    app_log_group_arn = "${aws_cloudwatch_log_group.app.arn}"
#    ecs_log_group_arn = "${aws_cloudwatch_log_group.ecs.arn}"
#  }
}

resource "aws_iam_role_policy" "ecs_instance" {
  name   = "ecs-instance-role"
  role   = "${aws_iam_role.iam_for_ecs_tasks.name}"
  policy = "${data.template_file.ecs_instance_profile.rendered}"
}
