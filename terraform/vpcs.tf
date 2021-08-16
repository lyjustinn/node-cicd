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
