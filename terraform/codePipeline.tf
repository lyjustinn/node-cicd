resource "aws_codepipeline" "ecr_cicd" {
    name = "ecr-codepipeline"
    role_arn = "${aws_iam_role.codepipeline.arn}"

    artifact_store {
        location = aws_s3_bucket.deployment_bucket.bucket
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
                S3Bucket = aws_s3_bucket.elb_source.bucket
                S3ObjectKey = "artifact.zip"
            }

            output_artifacts = [ "SourceArtifact" ]
        }
    }

    stage {
        name = "Deploy"

        action {
            name = "ELB"
            owner = "AWS"
            category = "Deploy"
            provider = "ElasticBeanstalk"
            version = 1

            configuration = {
                ApplicationName = "cicd"
                EnvironmentName = "cicd"
            }

            input_artifacts = [ "SourceArtifact" ]
        }
    }
}