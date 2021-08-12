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
                aws sts get-caller-identity
            }
        }
    }
}