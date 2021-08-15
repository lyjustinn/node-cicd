resource "aws_launch_template" "ecs_launch_template" {
    name_prefix = "cicd"
    image_id = "ami-09e67e426f25ce0d7"
    instance_type = "t2.micro"
}

resource "aws_autoscaling_group" "ecs" {
    name = "asg"
    min_size = 1
    max_size = 2
    availability_zones = var.ecs_az

    launch_template {
        id      = aws_launch_template.ecs_launch_template.id
        version = "$Latest"
    }

    tag {
        key = "AmazonECSManaged"
        value = ""
        propagate_at_launch = true
    }
}

resource "aws_ecs_capacity_provider" "ecs" {
    name = "cicd-provider"

    auto_scaling_group_provider {
        auto_scaling_group_arn = aws_autoscaling_group.ecs.arn
    }
}

resource "aws_ecs_cluster" "ecs" {
    name = "ecs-cd"
    capacity_providers = [ "cicd-provider" ]
}

resource "aws_ecs_task_definition" "ecs_task_def" {
    family = "ecs-cd-task-def"
    execution_role_arn = aws_iam_role.ecs_task_execution.arn
    requires_compatibilities = [ "EC2" ]
    memory = 512
    network_mode = "awsvpc"

    container_definitions = jsonencode([
        {
            name = "ecr-cicd"
            image = "ecr_cicd"
            essential = true
            portMappings = [
                {
                    hostPort = 80,
                    protocol = "tcp",
                    containerPort = "${var.container_port}"
                }
            ]
        }
    ])
}

resource "aws_ecs_service" "ecs_service" {
    name = "ecs-service"
    cluster = aws_ecs_cluster.ecs.id
    task_definition = aws_ecs_task_definition.ecs_task_def.arn
    desired_count = 1
    launch_type = "EC2"
    scheduling_strategy = "REPLICA"

    deployment_controller {
        type = "CODE_DEPLOY"
    }

    load_balancer {
        target_group_arn = aws_lb_target_group.ecs_tg.*.arn[0]
        container_name = "ecr-cicd"
        container_port = "${var.container_port}"
    }

    network_configuration {
        subnets = aws_subnet.ecs_subnet.*.id
        security_groups = [ aws_security_group.ecs_lb_sg.id ]
    }
}