resource "aws_ecr_repository" "ecr_cicd" {
    name = "ecr_cicd"
    image_tag_mutability = "MUTABLE"

    image_scanning_configuration {
      scan_on_push = true
    }

    tags = {
        Name = "ecr_cicd"
    }
}