@Library('microservices-shared-lib') _

pipeline {
    agent any

    environment {
        AWS_ACCOUNT_ID = '516466084972'
        AWS_REGION     = 'ap-south-2'
        IMAGE_NAME     = 'adservice'
        SERVICE_DIR    = 'src/adservice'
        ECR_URL        = "${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com"
    }

    tools {
        maven 'Maven'
    }

    stages {
        stage('Checkout Code') {
            steps {
                checkout scm
            }
        }

        stage('Maven Build, Test & SonarQube') {
            steps {
                mavenBuild("${SERVICE_DIR}", 'SonarQube-Server')
            }
        }

        stage('Trivy Filesystem Scan') {
            steps {
                trivyScan.fsScan("${SERVICE_DIR}")
            }
        }

        stage('Build, Image Scan & Push to ECR') {
            steps {
                dockerBuildPush(
                    serviceDir: "${SERVICE_DIR}",
                    imageName:  "${IMAGE_NAME}",
                    imageTag:   "${BUILD_NUMBER}",
                    awsRegion:  "${AWS_REGION}",
                    ecrUrl:     "${ECR_URL}"
                )
            }
        }
    }
}
