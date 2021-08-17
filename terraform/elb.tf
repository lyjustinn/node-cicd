resource "aws_elastic_beanstalk_application" "cicd" {
    name = "cicd"
    description = "cicd app with Terraform"

    appversion_lifecycle {
        service_role = aws_iam_role.elb_service.arn
        max_count = 4
        delete_source_from_s3 = true
    }
}

resource "aws_elastic_beanstalk_environment" "cicd" {
    name = "cicd"
    tier = "WebServer"
    solution_stack_name = var.elb_solution_stack
    application = aws_elastic_beanstalk_application.cicd.name
    
    setting {
        namespace = "aws:elasticbeanstalk:environment"
        name = "EnvironmentType"
        value = "SingleInstance"
    }

    setting {
        namespace = "aws:ec2:instances"
        name = "InstanceTypes"
        value = join(",", var.elb_instance_types)
    }

    setting {
        namespace = "aws:ec2:vpc"
        name      = "VPCId"
        value     = aws_vpc.elb.id
    }

    setting {
        namespace = "aws:ec2:vpc"
        name      = "Subnets"
        value     = aws_subnet.elb.id
    }

    setting {
        namespace = "aws:autoscaling:launchconfiguration"
        name = "IamInstanceProfile"
        value = aws_iam_instance_profile.elb.arn
    }
}