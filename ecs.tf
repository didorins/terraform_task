# resource "aws_ecs_capacity_provider" "capacity_provider" {
#   name = "${aws_autoscaling_group.asg.name}-provider"
#   auto_scaling_group_provider {
#     auto_scaling_group_arn         = aws_autoscaling_group.asg.arn
#     managed_termination_protection = "ENABLED"
#     managed_scaling {
#       maximum_scaling_step_size = 1
#       minimum_scaling_step_size = 1
#       target_capacity           = 2
#     }
#   }
#   depends_on = [
#     aws_iam_service_linked_role.ecs
#   ]
# }

#   setting {
#     name  = "containerInsights"
#     value = "true"
#   }


# resource "aws_iam_service_linked_role" "ecs" {
#   aws_service_name = "ecs.amazonaws.com"
# }


