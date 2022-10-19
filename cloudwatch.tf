# Cloudwatch alarms
# TODO : cloudwatch alarm to trigger scaling policy for simple scaling; integrate with sns topic > mail?

# Based on CPU of EC2
resource "aws_cloudwatch_metric_alarm" "alarmcpu" {
  alarm_name          = "CPU-ALARM"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "5"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "60"
  statistic           = "Maximum"
  threshold           = "90"
  #  alarm_actions       = [aws_sns_topic.sns.arn]
  #  ok_actions          = [aws_sns_topic.sns.arn]

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.asg.name
  }

  alarm_description = "This metric tracks EC2 CPU util and is triggered if X consecutive minutes CPU usage is above Y%"
  alarm_actions     = [aws_autoscaling_policy.scaling.arn]
}

# Based on request rate to LB 
resource "aws_cloudwatch_metric_alarm" "request-rate" {
  alarm_name          = "LB-REQUEST-ALARM"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  threshold           = "10"
  statistic           = "Sum"
  metric_name         = "RequestCount"
  namespace           = "AWS/ApplicationELB"
  unit                = "Count"
  period              = "60"

  #  alarm_actions       = [aws_sns_topic.sns.arn]
  #  ok_actions          = [aws_sns_topic.sns.arn]

  dimensions = {
    LoadBalancer = aws_lb.app-lb.arn_suffix
  }

  alarm_description = "This metric tracks LB requests and is triggered if requests exceed threshold over given periods."
}


/*
resource "aws_sns_topic"{

}
*/