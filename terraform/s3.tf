resource "aws_s3_bucket" "elb_source" {
    bucket = "elb_source"
    acl = "private"

    versioning {
        enabled = true
    }

    tags = {
      "Name" = "elb_source"
    }
}

resource "aws_s3_bucket" "codepipeline_artifacts" {
    bucket = "codepipeline_artifacts"
    acl = "private"

    versioning {
        enabled = true
    }

    tags = {
      "Name" = "codepipeline_artifacts"
    }
}