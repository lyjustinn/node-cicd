pipeline {
    agent any

    environment {
        BUILD = "${env.BUILD_NUMBER}"
        AWS_REGION = credentials('aws-region')
        AWS_ACCOUNT_ID = credentials('aws-account-id')
        AWS_REPOSITORY = credentials('aws-ecr-repository')
    }

    tools { nodejs "node" }

    stages {
        stage("build") {
            steps {
                echo "build stage"
                sh('npm ci')
            }
        }
        stage("test") {
            steps {
                echo "test stage"
                sh('npm run test --if-present')
            }
        }
        stage("aws-cred") {
            steps {
                sh 'aws sts get-caller-identity'
            }
        }
        stage("deploy") {
            steps {
                echo "push ${BUILD} image"
                sh('sudo docker build -t $AWS_REPOSITORY .')
                sh('aws ecr get-login-password --region $AWS_REGION | sudo docker login --username AWS --password-stdin $AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com')
                sh('sudo docker tag $AWS_REPOSITORY $AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/$AWS_REPOSITORY:$BUILD')
                sh('sudo docker push $AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/$AWS_REPOSITORY:$BUILD')
                sh('sudo docker tag $AWS_REPOSITORY $AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/$AWS_REPOSITORY:latest')
                sh('sudo docker push $AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/$AWS_REPOSITORY:latest')
            }
        }
        stage("cleanup") {
            steps {
                sh('sudo docker image prune -f')
                sh('sudo docker logout $AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com')
            }
        }
    }
}