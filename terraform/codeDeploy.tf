resource "aws_codedeploy_app" "ecs_codedeploy_app" {
    compute_platform = "ECS"
    name = "ecs-codedeploy-app"
}

resource "aws_codedeploy_deployment_group" "name" {
    app_name = aws_codedeploy_app.ecs_codedeploy_app.name
    deployment_group_name = "ecs-codedeploy-group"
    service_role_arn = aws_iam_role.codedeploy_ecs_role.arn
    deployment_config_name = "CodeDeployDefault.ECSAllAtOnce"

    deployment_style {
        deployment_type = "BLUE_GREEN"
        deployment_option = "WITH_TRAFFIC_CONTROL"
    }

    ecs_service {
        cluster_name = aws_ecs_cluster.ecs.name
        service_name = aws_ecs_service.ecs_service.name
    }

    blue_green_deployment_config {
        deployment_ready_option {
            action_on_timeout = "CONTINUE_DEPLOYMENT"
        }
    }

    load_balancer_info {
        target_group_pair_info {
            prod_traffic_route {
                listener_arns = aws_lb_listener.ecs_lb_listener.*.arn
            }

            target_group {
                name = aws_lb_target_group.ecs_tg.*.name[0]
            }

            target_group {
                name = aws_lb_target_group.ecs_tg.*.name[1]
            }
        }
    }
}