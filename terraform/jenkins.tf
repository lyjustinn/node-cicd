resource "aws_vpc" "jenkins-vpc" {
    cidr_block = "10.0.0.0/16"
    enable_dns_hostnames = true
    enable_dns_support = true

    tags = {
      "Name" = "jenkins-vpc"
    }
}

resource "aws_internet_gateway" "jenkins-ig" {
    vpc_id = aws_vpc.jenkins-vpc.id

    tags = {
        Name="jenkins-internet-gateway"
    }
}

resource "aws_route_table" "jenkins-vpc-rt" {
    vpc_id = aws_vpc.jenkins-vpc.id

    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.jenkins-ig.id
    }

    tags = {
        Name="jenkins-route-table"
    }
}

resource "aws_subnet" "jenkins-subnet" {
    vpc_id = aws_vpc.jenkins-vpc.id
    cidr_block = "10.0.0.0/24"
    availability_zone = "${var.region}a"

    tags = {
        Name="jenkins-subnet"
    }
}

resource "aws_route_table_association" "jenkins-association" {
    subnet_id = aws_subnet.jenkins-subnet.id
    route_table_id = aws_route_table.jenkins-vpc-rt.id
}

resource "aws_security_group" "jenkins-sg" {
    name = "jenkins-security"
    description = "Security group for jenkins server"
    vpc_id = aws_vpc.jenkins-vpc.id

    ingress {
        from_port = 22
        to_port = 22
        protocol = "tcp"
        description = "Allow ssh from specified ip"
        cidr_blocks = [ var.ssh-ip ]
    }

    ingress {
        from_port = 8080
        to_port = 8080
        protocol = "tcp"
        description = "Allow jenkins access from specified ip"
        cidr_blocks = [ var.ssh-ip ]
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

resource "aws_network_interface" "jenkins-nic" {
    subnet_id = aws_subnet.jenkins-subnet.id
    private_ips = [ "10.0.0.50" ]
    security_groups = [ aws_security_group.jenkins-sg.id ]

    tags = {
      Name = "jenkins-network-interface"
    }
}

resource "aws_eip" "jenkins-eip" {
    vpc = true
    network_interface = aws_network_interface.jenkins-nic.id
    associate_with_private_ip = "10.0.0.50"
    depends_on = [
      aws_internet_gateway.jenkins-ig
    ]

    tags = {
      Name = "jenkins-elastic-ip"
    }
}

resource "aws_instance" "jenkins-instance" {
    ami = "ami-09e67e426f25ce0d7"
    instance_type = "t2.micro"
    availability_zone = "${var.region}a"
    key_name = "jenkins-key2"
    
    network_interface {
        device_index = 0
        network_interface_id = aws_network_interface.jenkins-nic.id
    }

    user_data = <<-EOF
                #!/bin/bash
                echo "Install OpenJDK"
                sudo apt update -y
                sudo apt install default-jre -y

                echo "Install Docker"
                sudo apt-get remove docker docker-engine docker.io containerd runc -y
                sudo apt-get update -y
                sudo apt-get install \
                    apt-transport-https \
                    ca-certificates \
                    curl \
                    gnupg \
                    lsb-release -y
                curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
                echo \
                    "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \
                    $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
                sudo apt-get update -y
                sudo apt-get install docker-ce docker-ce-cli containerd.io -y

                echo "Install Jenkins"
                wget -q -O - https://pkg.jenkins.io/debian-stable/jenkins.io.key | sudo apt-key add -
                sudo sh -c 'echo deb https://pkg.jenkins.io/debian-stable binary/ > \
                    /etc/apt/sources.list.d/jenkins.list'
                sudo apt update -y
                sudo apt install jenkins -y
                sudo systemctl start jenkins

                EOF

    tags = {
      Name = "jenkins-instance"
    }
}

output "jenkins-eip" {
    value = aws_eip.jenkins-eip.public_ip
}
output "jenkins-public-dns" {
    value = aws_instance.jenkins-instance.public_dns
}
