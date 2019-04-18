# Set up cloudwatch group and log stream and retain logs for 30 days
resource "aws_cloudwatch_log_group" "morse_log_group" {
  name              = "/ecs/morse-app"
  retention_in_days = 30

  tags {
    Name = "morse-log-group"
  }
}

resource "aws_cloudwatch_log_stream" "morse_log_stream" {
  name           = "morse-log-stream"
  log_group_name = "${aws_cloudwatch_log_group.morse_log_group.name}"
}
