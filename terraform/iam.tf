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

resource "aws_iam_instance_profile" "jenkins_profile" {
    name = "jenkins_profile"
    role = aws_iam_role.jenkins_iam.name
}

resource "aws_iam_role" "codedeploy_ecs_role" {
    name = "code-deploy-ecs"
    assume_role_policy = jsonencode({
        Version = "2012-10-17",
        Statement = [
            {
                Action = "sts:AssumeRole"
                Sid = ""
                Effect = "Allow"
                Principal = {
                    Service = "codedeploy.amazonaws.com"
                }
            }
        ]
    })
}

data "aws_iam_policy" "AWSCodeDeployRoleForECS" {
    arn = "arn:aws:iam::aws:policy/AWSCodeDeployRoleForECS"
}

resource "aws_iam_role_policy_attachment" "codedeploy_ecs_policy" {
    role = aws_iam_role.codedeploy_ecs_role.name
    policy_arn = data.aws_iam_policy.AWSCodeDeployRoleForECS.arn
}

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

