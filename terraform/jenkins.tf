resource "aws_network_interface" "jenkins" {
    subnet_id = aws_subnet.jenkins_subnet.id
    private_ips = [ "10.0.0.50" ]
    security_groups = [ aws_security_group.jenkins_sg.id ]

    tags = {
      Name = "jenkins_network_interface"
    }
}

resource "aws_eip" "jenkins" {
    vpc = true
    network_interface = aws_network_interface.jenkins.id
    associate_with_private_ip = "10.0.0.50"
    depends_on = [
      aws_internet_gateway.jenkins_ig
    ]

    tags = {
      Name = "jenkins_elastic_ip"
    }
}

resource "aws_instance" "jenkins" {
    ami = "ami-09e67e426f25ce0d7"
    instance_type = "t2.micro"
    availability_zone = "${var.region}a"
    key_name = "jenkins-key2"
    iam_instance_profile = aws_iam_instance_profile.jenkins_profile.name
    
    network_interface {
        device_index = 0
        network_interface_id = aws_network_interface.jenkins.id
    }

    user_data = <<-EOF
                #!/bin/bash

                echo "Install zip"
                sudo apt-get update -y
                sudo apt-get install zip unzip -y
                
                echo "AWS CLI"
                curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
                unzip awscliv2.zip
                sudo ./aws/install

                echo "Install OpenJDK"
                sudo apt update -y
                sudo apt install default-jre -y

                echo "Install Jenkins"
                wget -q -O - https://pkg.jenkins.io/debian-stable/jenkins.io.key | sudo apt-key add -
                sudo sh -c 'echo deb https://pkg.jenkins.io/debian-stable binary/ > \
                    /etc/apt/sources.list.d/jenkins.list'
                sudo apt update -y
                sudo apt install jenkins -y
                sudo systemctl start jenkins

                EOF

    tags = {
      Name = "jenkins_instance"
    }
}

output "jenkins_eip" {
    value = aws_eip.jenkins.public_ip
}
output "jenkins_public_dns" {
    value = aws_instance.jenkins.public_dns
}
