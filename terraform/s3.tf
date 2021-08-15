data "archive_file" "source_artifact" {
    type = "zip"
    output_path = "SourceArtifact.json"
    
    source {
        content = jsonencode({
            executionRoleArn = "${aws_iam_role.ecs_task_execution.arn}"
            containerDefinitions = [
                {
                    name = "ecr-cicd"
                    image = "<IMAGE1_NAME>"
                    essential = true
                    portMappings = [
                        {
                            hostPort = 80
                            protocol = "tcp"
                            containerPort = "${var.container_port}"
                        }
                    ]
                }
            ]
            requiresCompatibilities = [
                "EC2"
            ]
            networkMode = "awsvpc"
            family = "ecs-cd-task-def"
        })

        filename = "taskdef.json"
    }

    source {
        content = yamlencode({
            version = 0
            Resources = [
                {
                    TargetService = {
                        Type = "AWS::ECS::Service",
                        Properties = {
                            TaskDefinition = "<TASK_DEFINITION>"
                            LoadBalancerInfo = {
                                ContainerName = "ecr-cicd"
                                ContainerPort = "${var.container_port}"
                            }
                        }
                    }
                }
            ]
        })

        filename = "appspec.yaml"
    }
}
resource "aws_s3_bucket" "artifacts" {
    bucket = "artifacts"
    acl    = "private"

    tags = {
        Name = "artifacts"
    }
}

resource "aws_s3_bucket_object" "source_artifact" {
    bucket = aws_s3_bucket.artifacts.id
    key = "SourceArtifact.zip"
    source = "${data.archive_file.source_artifact.output_path}"
}

resource "aws_s3_bucket" "codepipeline" {
    bucket = "codepipeline"
    acl    = "private"

    tags = {
        Name = "codepipeline"
    }
}