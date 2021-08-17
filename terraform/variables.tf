variable "region" {
    type = string
}

variable "ssh_ip" {
    type = string
}

variable "elb_solution_stack" {
    type = string
}

variable "elb_instance_types" {
    default = [ "t2.micro", "t3.micro" ]
}
variable "elb_az" {
    type = string
}