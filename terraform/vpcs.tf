resource "aws_vpc" "jenkins_vpc" {
    cidr_block = "10.0.0.0/16"
    enable_dns_hostnames = true
    enable_dns_support = true

    tags = {
      "Name" = "jenkins_vpc"
    }
}

resource "aws_internet_gateway" "jenkins_ig" {
    vpc_id = aws_vpc.jenkins_vpc.id

    tags = {
        Name="jenkins_internet_gateway"
    }
}

resource "aws_route_table" "jenkins_vpc_rt" {
    vpc_id = aws_vpc.jenkins_vpc.id

    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.jenkins_ig.id
    }

    tags = {
        Name="jenkins_route_table"
    }
}

resource "aws_subnet" "jenkins_subnet" {
    vpc_id = aws_vpc.jenkins_vpc.id
    cidr_block = "10.0.0.0/24"
    availability_zone = "${var.region}a"

    tags = {
        Name="jenkins_subnet"
    }
}

resource "aws_route_table_association" "jenkins_association" {
    subnet_id = aws_subnet.jenkins_subnet.id
    route_table_id = aws_route_table.jenkins_vpc_rt.id
}

resource "aws_security_group" "jenkins_sg" {
    name = "jenkins_security"
    description = "Security group for jenkins server"
    vpc_id = aws_vpc.jenkins_vpc.id

    ingress {
        from_port = 22
        to_port = 22
        protocol = "tcp"
        description = "Allow ssh from specified ip"
        cidr_blocks = [ var.ssh_ip ]
    }

    ingress {
        from_port = 8080
        to_port = 8080
        protocol = "tcp"
        description = "Allow jenkins access from specified ip"
        cidr_blocks = [ "0.0.0.0/0" ]
    }

    egress {
        from_port        = 0
        to_port          = 0
        protocol         = "-1"
        cidr_blocks      = ["0.0.0.0/0"]
        ipv6_cidr_blocks = ["::/0"]
    }

    tags = {
        Name = "Allow web connections to jenkins"
    }
}

resource "aws_vpc" "ecs_vpc" {
    cidr_block = "10.1.0.0/16"
    enable_dns_hostnames = true
    enable_dns_support = true

    tags = {
        Name = "ecs_vpc"
    }
}

resource "aws_internet_gateway" "ecs_ig" {
    vpc_id = aws_vpc.ecs_vpc.id

    tags = {
        Name = "ecs_internet_gateway"
    }
}

resource "aws_subnet" "ecs_subnet" {
    count = length(var.ecs_subnet_cidrs)

    vpc_id = aws_vpc.ecs_vpc.id
    cidr_block = "${var.ecs_subnet_cidrs[count.index]}"
    availability_zone = "${var.ecs_az[count.index]}"

    tags = {
        Name="ecs_subnet_${count.index}"
    }
}

resource "aws_route_table" "ecs_rt" {
    vpc_id = aws_vpc.ecs_vpc.id

    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.ecs_ig.id
    }

    tags = {
        Name = "ecs_rt"
    }
}

resource "aws_route_table_association" "ecs_association" {
    count = length(var.ecs_subnet_cidrs)

    subnet_id = aws_subnet.ecs_subnet.*.id[count.index]
    route_table_id = aws_route_table.ecs_rt.id
}

resource "aws_security_group" "ecs_lb_sg" {
    name = "ecs_lb_security"
    description = "Security group for ecs load balancer"
    vpc_id = aws_vpc.ecs_vpc.id

    ingress {
        from_port = 22
        to_port = 22
        protocol = "tcp"
        description = "Allow ssh from specified ip"
        cidr_blocks = [ var.ssh_ip ]
    }

    ingress {
        from_port = 80
        to_port = 80
        protocol = "tcp"
        description = "allow 80 for http traffic"
        cidr_blocks = [ "0.0.0.0/0" ]
    }

    egress {
        from_port        = 0
        to_port          = 0
        protocol         = "-1"
        cidr_blocks      = ["0.0.0.0/0"]
        ipv6_cidr_blocks = ["::/0"]
    }

    tags = {
        Name = "Allow web connections to load balancer"
    }
}