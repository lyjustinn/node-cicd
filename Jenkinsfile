pipeline {
    agent any

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
    }
}