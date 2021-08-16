pipeline {
    agent any

    environment {
        BUILD = "${env.BUILD_NUMBER}"
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
        stage("upload") {
            steps {
                sh 'ls'
            }
        }
    }
}