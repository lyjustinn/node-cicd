resource "aws_launch_template" "ecs_launch_template" {
    name_prefix = "cicd"
    image_id = "ami-0e5fb9632ceee168f"
    instance_type = "t2.micro"
    user_data = base64encode("#!/bin/bash\necho ECS_CLUSTER=ecs-cd >> /etc/ecs/ecs.config")
    ebs_optimized = false
    update_default_version = true
    vpc_security_group_ids = [ aws_security_group.ecs_lb_sg.id ]

    iam_instance_profile {
        arn = aws_iam_instance_profile.ecs_instance.arn
    }
}

resource "aws_autoscaling_group" "ecs" {
    name = "asg"
    min_size = 1
    max_size = 2
    vpc_zone_identifier = aws_subnet.ecs_subnet.*.id

    launch_template {
        id      = aws_launch_template.ecs_launch_template.id
        version = "$Latest"
    }
}

resource "aws_ecs_cluster" "ecs" {
    name = "ecs-cd"
}

resource "aws_ecs_task_definition" "ecs_task_def" {
    family = "ecs-cd-task-def"
    execution_role_arn = aws_iam_role.ecs_task_execution.arn
    requires_compatibilities = [ "EC2" ]
    memory = 50
    network_mode = "awsvpc"

    container_definitions = jsonencode([
        {
            name = "ecr-cicd"
            image = "ecr_cicd"
            essential = true
            portMappings = [
                {
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
    task_definition = "${aws_ecs_task_definition.ecs_task_def.arn}"
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