pipeline {
    agent any

    environment {
        BUILD = "${env.BUILD_NUMBER}"
        BUCKET = credentials('bucket-name')
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
        stage("upload") {
            steps {
                echo "upload stage"
                sh 'pwd;ls'
                sh "mkdir -p /build/artifacts/s3/ && zip -r /build/artifacts/s3/artifact${BUILD}.zip dir1 -x terraform/**\* node_modules/**\*"
                sh ('aws s3 cp /build/artifacts/s3/artifact$BUILD.zip s3://$BUCKET/')
                sh 'ls /build/artifacts/s3/'
            }
        }
    }
}