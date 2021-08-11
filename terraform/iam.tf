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

resource "aws_iam_role_policy" "jenkins_ecr_policy" {
    name = "jenkins_ecr_policy"
    role = aws_iam_role.jenkins_iam.id

    policy = jsonencode({
        Version = "2012-10-17"
        Statement = [
            {
                Effect = "Allow"
                Action = [
                    "ecr:BatchCheckLayerAvailability",
                    "ecr:CompleteLayerUpload",
                    "ecr:InitiateLayerUpload",
                    "ecr:PutImage",
                    "ecr:UploadLayerPart",
                    "ecr:TagResource",
                    "ecr:UntagResource"
                ]
                Resource = "${aws_ecr_repository.ecr_cicd.arn}"
            }
        ]
    })
}

resource "aws_iam_instance_profile" "jenkins_profile" {
    name = "jenkins_profile"
    role = aws_iam_role.jenkins_iam.name
}