resource "aws_s3_bucket" "elb_source" {
    bucket = "elb-source"
    acl = "private"

    versioning {
        enabled = true
    }

    tags = {
      "Name" = "elb-source"
    }
}

resource "aws_s3_bucket" "deployment_bucket" {
    bucket_prefix = "cpipeline-"
    acl = "private"

    versioning {
        enabled = true
    }

    tags = {
      "Name" = "cpipeline-bucket"
    }
}