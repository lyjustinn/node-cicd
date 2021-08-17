resource "aws_iam_role" "jenkins_iam" {
    name = "jenkins_iam"

    assume_role_policy = jsonencode({
        Version = "2012-10-17"
        Statement = [
            {
                Action = "sts:AssumeRole"
                Effect = "Allow"
                Sid = ""
                Principal = {
                    Service = "ec2.amazonaws.com"
                }
            },
        ]
    })

    tags = {
        Name = "jenkins_iam"
    }
}

resource "aws_iam_role_policy" "s3_access" {
    name = "s3_access"
    role = aws_iam_role.jenkins_iam.id

    policy = jsonencode({
        Version = "2012-10-17",
        Statement = [
            {
                Effect = "Allow",
                Action = [
                    "s3:PutObject",
                    "s3:PutObjectAcl",
                    "s3:GetObject",
                    "s3:GetObjectAcl",
                    "s3:DeleteObject"
                ],
                Resource = "${aws_s3_bucket.elb_source.arn}/*"
            }
        ]
    })
}


resource "aws_iam_instance_profile" "jenkins_profile" {
    name = "jenkins_profile"
    role = aws_iam_role.jenkins_iam.name
}

# data "aws_iam_policy" "AWSCodeDeployRoleForECS" {
#     arn = "arn:aws:iam::aws:policy/AWSCodeDeployRoleForECS"
# }

# resource "aws_iam_role_policy_attachment" "codedeploy_ecs_policy" {
#     role = aws_iam_role.codedeploy_ecs_role.name
#     policy_arn = data.aws_iam_policy.AWSCodeDeployRoleForECS.arn
# }

resource "aws_iam_role" "codepipeline" {
    name = "codepipeline-ecs-cicd"

    assume_role_policy = jsonencode({
        Version = "2012-10-17",
        Statement = [
            {
                Action = "sts:AssumeRole"
                Sid = ""
                Effect = "Allow"
                Principal = {
                    Service = "codepipeline.amazonaws.com"
                }
            }
        ]
    })
}

resource "aws_iam_role_policy" "codepipeline" {
    name = "codepipline-ecs-cicd"
    role = aws_iam_role.codepipeline.id

    policy = file("${abspath(path.module)}/json/codepipelinepolicy.json")
}

resource "aws_iam_role" "elb_service" {
    name = "elb_service"

    assume_role_policy = jsonencode({
        Version = "2012-10-17",
        Statement = [
            {
                Action = "sts:AssumeRole"
                Sid = ""
                Effect = "Allow"
                Principal = {
                    Service = "elasticbeanstalk.amazonaws.com"
                }
            }
        ]
    })
}

data "aws_iam_policy" "AWSElasticBeanstalkEnhancedHealth" {
    arn = "arn:aws:iam::aws:policy/service-role/AWSElasticBeanstalkEnhancedHealth"
}

resource "aws_iam_role_policy_attachment" "elb_enhancedhealth" {
    role = aws_iam_role.elb_service.name
    policy_arn = data.aws_iam_policy.AWSElasticBeanstalkEnhancedHealth.arn
}

data "aws_iam_policy" "AWSElasticBeanstalkManagedUpdatesCustomerRolePolicy" {
    arn = "arn:aws:iam::aws:policy/AWSElasticBeanstalkManagedUpdatesCustomerRolePolicy"
}

resource "aws_iam_role_policy_attachment" "elb_managedupdates" {
    role = aws_iam_role.elb_service.name
    policy_arn = data.aws_iam_policy.AWSElasticBeanstalkManagedUpdatesCustomerRolePolicy.arn
}

resource "aws_iam_role" "elb_instance" {
    name = "elb_instance"

    assume_role_policy = jsonencode({
        Version = "2012-10-17"
        Statement = [
            {
                Action = "sts:AssumeRole"
                Effect = "Allow"
                Sid = ""
                Principal = {
                    Service = "ec2.amazonaws.com"
                }
            },
        ]
    })

    tags = {
        Name = "elb_instance"
    }
}

data "aws_iam_policy" "AWSElasticBeanstalkWebTier" {
    arn = "arn:aws:iam::aws:policy/AWSElasticBeanstalkWebTier"
}

resource "aws_iam_role_policy_attachment" "elb_webtier" {
    role = aws_iam_role.elb_instance.name
    policy_arn = data.aws_iam_policy.AWSElasticBeanstalkWebTier.arn
}

resource "aws_iam_instance_profile" "elb" {
    name = "elb_profile"
    role = aws_iam_role.elb_instance.name
}