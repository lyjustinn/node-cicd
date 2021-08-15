variable "region" {
    type = string
}

variable "ssh_ip" {
    type = string
}

variable "ecs_az" {
    description = "List of availability zones for subnets in the ecs vpc"
    type = tuple([string, string])
}

variable "ecs_subnet_cidrs" {
    description = "List of CIDR blocks for subnets in the ecs vpc"
    default = ["10.1.0.0/24", "10.1.1.0/24"]
    type = tuple([string, string])
}

variable "ecs_lb_ports" {
    description = "List of ports for load balancer in the ecs vpc"
    default = ["80", "8080"]
    type = tuple([string, string])
}

variable "container_port" {
    description = "Port number the application will run on in its container"
    type = number
}

variable "image_tag" {
    description = "image tag for ecr source action in codepipeline"
    default = "latest"
    type = string
}