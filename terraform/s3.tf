data "archive_file" "source_artifact" {
    type = "zip"
    output_path = "${abspath(path.module)}/SourceArtifact.zip"
    
    source {
        content = "{\"executionRoleArn\": \"${aws_iam_role.ecs_task_execution.arn}\",\n\"containerDefinitions\": [{\"name\": \"ecr-cicd\",\"image\": \"<IMAGE1_NAME>\",\"essential\": true,\"portMappings\": [{\"protocol\": \"tcp\",\"containerPort\": ${var.container_port}}]}],\n\"requiresCompatibilities\": [\"EC2\"],\n\"networkMode\": \"awsvpc\",\n\"family\": \"ecs-cd-task-def\",\n\"memory\": \"512\"}"

        filename = "taskdef.json"
    }
# X"version: 0.0\n\tResources:\n- TargetService:\n\tType: AWS::ECS::Service\nProperties:\n\n\tTaskDefinition: <TASK_DEFINITION>\n\nLoadBalancerInfo:\n\nContainerName: \"ecr-cicd\"\n\nContainerPort: ${var.container_port}"
    source {
        content = "version: 0.0\nResources:\n  - TargetService:\n      Type: AWS::ECS::Service\n      Properties:\n        TaskDefinition: <TASK_DEFINITION>\n        LoadBalancerInfo:\n          ContainerName: \"ecr-cicd\"\n          ContainerPort: ${var.container_port}"

        filename = "appspec.yaml"
    }
}
resource "aws_s3_bucket" "artifacts" {
    bucket_prefix = "cicd-artifacts"
    acl    = "private"

    versioning {
        enabled = true
    }

    tags = {
        Name = "cicd-artifacts"
    }
}

resource "aws_s3_bucket_object" "source_artifact" {
    bucket = aws_s3_bucket.artifacts.id
    key = "SourceArtifact.zip"
    source = "${data.archive_file.source_artifact.output_path}"
}

resource "aws_s3_bucket" "codepipeline" {
    bucket_prefix  = "cicd-codepipeline"
    acl    = "private"
    
    versioning {
        enabled = true
    }

    tags = {
        Name = "cicd-codepipeline"
    }
}