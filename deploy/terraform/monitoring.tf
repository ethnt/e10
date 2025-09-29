locals {
  aws_instances = {
    gateway = aws_instance.gateway,
    monitor = aws_instance.monitor,
    bastion = aws_instance.bastion
  }
}

resource "aws_sns_topic" "ec2_alerts" {
  name = "ec2-alerts"
}

resource "aws_sns_topic_subscription" "email_notification" {
  topic_arn = aws_sns_topic.ec2_alerts.arn
  protocol  = "email"
  endpoint  = "e10@turkeltaub.dev"
}

resource "aws_cloudwatch_metric_alarm" "status_check" {
  for_each = local.aws_instances

  alarm_name          = "${each.key}-status-check-failed"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "StatusCheckFailed"
  namespace           = "AWS/EC2"
  period              = "60"
  statistic           = "Maximum"
  threshold           = "0"
  alarm_actions       = [aws_sns_topic.ec2_alerts.arn]
  ok_actions          = [aws_sns_topic.ec2_alerts.arn]

  dimensions = {
    InstanceId = each.value.id
  }
}

resource "aws_cloudwatch_metric_alarm" "system_status_check" {
  for_each = local.aws_instances

  alarm_name          = "${each.key}-system-status-check-failed"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "StatusCheckFailed_System"
  namespace           = "AWS/EC2"
  period              = "60"
  statistic           = "Maximum"
  threshold           = "0"
  alarm_actions       = [aws_sns_topic.ec2_alerts.arn]
  ok_actions          = [aws_sns_topic.ec2_alerts.arn]

  dimensions = {
    InstanceId = each.value.id
  }
}

resource "aws_cloudwatch_metric_alarm" "instance_status_check" {
  for_each = local.aws_instances

  alarm_name          = "${each.key}-instance-status-check-failed"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "StatusCheckFailed_System"
  namespace           = "AWS/EC2"
  period              = "60"
  statistic           = "Maximum"
  threshold           = "0"
  alarm_actions       = [aws_sns_topic.ec2_alerts.arn]
  ok_actions          = [aws_sns_topic.ec2_alerts.arn]

  dimensions = {
    InstanceId = each.value.id
  }
}


# resource "aws_cloudwatch_metric_alarm" "monitor_status_check" {
#   for_each = local.instances

#   alarm_name          = "monitor-status-check-failed"
#   comparison_operator = "GreaterThanThreshold"
#   evaluation_periods  = 2
#   metric_name         = "StatusCheckFailed"
#   namespace           = "AWS/EC2"
#   period              = "60"
#   statistic           = "Maximum"
#   threshold           = "0"
#   alarm_actions       = [aws_sns_topic.ec2_alerts.arn]
#   ok_actions          = [aws_sns_topic.ec2_alerts.arn]

#   dimensions = {
#     InstanceId = aws_instance.monitor.id
#   }
# }

# resource "aws_cloudwatch_metric_alarm" "monitor_system_status_check" {
#   alarm_name          = "monitor-system-status-check-failed"
#   comparison_operator = "GreaterThanThreshold"
#   evaluation_periods  = 2
#   metric_name         = "StatusCheckFailed_System"
#   namespace           = "AWS/EC2"
#   period              = "60"
#   statistic           = "Maximum"
#   threshold           = "0"
#   alarm_actions       = [aws_sns_topic.ec2_alerts.arn]
#   ok_actions          = [aws_sns_topic.ec2_alerts.arn]

#   dimensions = {
#     InstanceId = aws_instance.monitor.id
#   }
# }

# resource "aws_cloudwatch_metric_alarm" "monitor_instance_status_check" {
#   alarm_name          = "monitor-instance-status-check-failed"
#   comparison_operator = "GreaterThanThreshold"
#   evaluation_periods  = 2
#   metric_name         = "StatusCheckFailed_System"
#   namespace           = "AWS/EC2"
#   period              = "60"
#   statistic           = "Maximum"
#   threshold           = "0"
#   alarm_actions       = [aws_sns_topic.ec2_alerts.arn]
#   ok_actions          = [aws_sns_topic.ec2_alerts.arn]

#   dimensions = {
#     InstanceId = aws_instance.monitor.id
#   }
# }

# resource "aws_cloudwatch_metric_alarm" "gateway_status_check" {
#   alarm_name          = "gateway-status-check-failed"
#   comparison_operator = "GreaterThanThreshold"
#   evaluation_periods  = 2
#   metric_name         = "StatusCheckFailed"
#   namespace           = "AWS/EC2"
#   period              = "60"
#   statistic           = "Maximum"
#   threshold           = "0"
#   alarm_actions       = [aws_sns_topic.ec2_alerts.arn]
#   ok_actions          = [aws_sns_topic.ec2_alerts.arn]

#   dimensions = {
#     InstanceId = aws_instance.gateway.id
#   }
# }

# resource "aws_cloudwatch_metric_alarm" "gateway_system_status_check" {
#   alarm_name          = "gateway-system-status-check-failed"
#   comparison_operator = "GreaterThanThreshold"
#   evaluation_periods  = 2
#   metric_name         = "StatusCheckFailed_System"
#   namespace           = "AWS/EC2"
#   period              = "60"
#   statistic           = "Maximum"
#   threshold           = "0"
#   alarm_actions       = [aws_sns_topic.ec2_alerts.arn]
#   ok_actions          = [aws_sns_topic.ec2_alerts.arn]

#   dimensions = {
#     InstanceId = aws_instance.gateway.id
#   }
# }

# resource "aws_cloudwatch_metric_alarm" "gateway_instance_status_check" {
#   alarm_name          = "gateway-instance-status-check-failed"
#   comparison_operator = "GreaterThanThreshold"
#   evaluation_periods  = 2
#   metric_name         = "StatusCheckFailed_System"
#   namespace           = "AWS/EC2"
#   period              = "60"
#   statistic           = "Maximum"
#   threshold           = "0"
#   alarm_actions       = [aws_sns_topic.ec2_alerts.arn]
#   ok_actions          = [aws_sns_topic.ec2_alerts.arn]

#   dimensions = {
#     InstanceId = aws_instance.gateway.id
#   }
# }
