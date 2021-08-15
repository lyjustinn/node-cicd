resource "aws_lb" "ecs_lb" {
    name = "ecs-lb"
    load_balancer_type = "application"
    ip_address_type = "ipv4"
    subnets = aws_subnet.ecs_subnet.*.id

    tags = {
        Environment = "production"
        Name = "ecs_lb"
    }
}

resource "aws_lb_target_group" "ecs_tg" {
    count = length(var.ecs_lb_ports)

    name = "ecs-tg-${var.ecs_lb_ports[count.index]}"
    port = var.ecs_lb_ports[count.index]
    protocol = "HTTP"
    vpc_id = aws_vpc.ecs_vpc.id
    target_type = "ip"

    tags = {
        Environment = "production"
        Name = "ecs_tg_${var.ecs_lb_ports[count.index]}"
    }

}

resource "aws_lb_listener" "ecs_lb_listener" {
    count = length(var.ecs_lb_ports)

    load_balancer_arn = aws_lb.ecs_lb.arn
    port = "${var.ecs_lb_ports[count.index]}"
    protocol = "HTTP"

    default_action {
        type = "forward"
        target_group_arn = "${aws_lb_target_group.ecs_tg.*.arn[0]}"
    }
}