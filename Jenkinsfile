pipeline {
    agent any

    environment {
        BUILD = env.BUILD_NUMBER_NUMBER
        AWS_REGION = credentials('aws-region')
        AWS_ACCOUNT_ID = credentials('aws-account-id')
        AWS_REPOSITORY = credentials('aws-ecr-repository')
    }

    stages {
        stage("hello-world") {
            steps {
                echo "hello world"
            }
        }
        stage("aws-cred") {
            steps {
                sh 'aws sts get-caller-identity'
            }
        }
        stage("push-image") {
            steps {
                echo 'push $BUILD image'
                sh '
                    sudo docker pull hello-world
                    aws ecr get-login-password --region $AWS_REGION | docker login --username AWS --password-stdin $AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com
                    sudo docker tag hello-world $AWS_ACCOUNT_ID.dkr.ecr.$REGION.amazonaws.com/$AWS_REPOSITORY:$BUILD
                    sudo docker push $AWS_ACCOUNT_ID.dkr.ecr.$REGION.amazonaws.com/$AWS_REPOSITORY:$BUILD
                '
            }
        }
    }
}