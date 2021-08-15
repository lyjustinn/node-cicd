resource "aws_codepipeline" "ecr_cicd" {
    name = "ecr-codepipeline"
    role_arn = "${aws_iam_role.codepipeline.arn}"

    artifact_store {
        location = aws_s3_bucket.codepipeline.bucket
        type = "S3"
    }

    stage {
        name = "Source"

        action {
            name = "S3"
            owner = "AWS"
            category = "Source"
            provider = "S3"
            version = 1

            configuration = {
                S3Bucket = aws_s3_bucket.artifacts.bucket
                S3ObjectKey = "SourceArtifact.zip"
            }

            output_artifacts = [ "SourceArtifact" ]
        }

        action {
            name = "ECR"
            owner = "AWS"
            category = "Source"
            provider = "ECR"
            version = 1

            configuration = {
                RepositoryName = "ecr_cicd"
                ImageTag = "${var.image_tag}"
            }

            output_artifacts = ["Image"]
        }
    }

    stage {
        name = "Deploy"

        action {
            name = "ECR"
            category = "Deploy"
            owner = "AWS"
            provider = "CodeDeployToECS"
            version = 1

            input_artifacts = [ "SourceArtifact", "Image" ]

            configuration = {
                ApplicationName = aws_codedeploy_app.ecs_codedeploy_app.name
                DeploymentGroupName = aws_codedeploy_deployment_group.ecs.id
                TaskDefinitionTemplateArtifact = "SourceArtifact"
                TaskDefinitionTemplatePath = "taskdef.json"
                AppSpecTemplateArtifact = "SourceArtifact"
                AppSpecTemplatePath = "appspec.yaml"
                Image1ArtifactName = "Image"
                Image1ContainerName = "IMAGE1_NAME"
            }
        }
    }
}