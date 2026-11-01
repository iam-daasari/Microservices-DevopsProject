pipeline {
    agent any

    environment {
        AWS_ACCOUNT_ID = '516466084972'
        AWS_REGION     = 'ap-south-2'
        IMAGE_NAME     = 'adservice'
        ECR_URL        = "${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com"
    }       

    tools{
         maven 'Maven'
    }

    stages {
            stage('checkout code') {
                steps {
                     echo "===== Stage 1:pulling code from github repostiory ====="
                     checkout scm 
                }
                     post {
                        success {
                            echo 'code pull is successfully completed'
                        }
                        failure {
                            echo 'failed pulling the code from github repo'
                        }
                     }
            }

            stage('clean & validate'){
                    steps {
                        echo "===== stage 2: cleaning the older build files and validating the pom.xml ====="
                        dir('src/adservice') {
                          sh 'mvn clean validate'
                        }                    
                    }

                    post {
                        success {
                            echo 'clean and validate successfully completed!'
                        }
                        failure {
                            echo 'clean and validate failed! check the console for logs'
                        }
                    }
                }                

            stage('compile adservice code') {
               steps {
                 echo "===== stage 3:Compiling the adservice code ====="
                 dir('src/adservice'){
                    sh 'mvn compile'
                 }
               }     

                post {
                    success {
                        echo 'compilation successfully completed'
                    }
                    failure {
                        echo 'compilation failed. check console for the logs'
                    }
                }
            }

          stage('Unit-Test of adservice') {
                steps{
                    echo "===== stage 4: Running Unit Tests of adservice ====="
                    dir('src/adservice') {
                        sh 'mvn test'
                    }
                }
                post {
                    success {
                        echo "successfully completed unit-test of adservice"
                    }
                    failure {
                        echo "unit-test failed!  Fix before proceeding"
                    }
                }
            }

        stage('Parallel Quality & Security Checks') {
           parallel {
               stage('sonarqube analysis') {
                   steps {
                       echo "===== stage 4: sonarqube analysis ====="
                       withSonarQubeEnv('SonarQube-Server') {
                            dir('src/adservice') {
                               sh 'mvn org.sonarsource.scanner.maven:sonar-maven-plugin:sonar'
                        }
                    }
                }
                post {
                    success {
                        echo "SonarQube analysis successfully completed"
                    }
                    failure {
                        echo "SonarQube analysis failed!Check sonarQube server console logs "
                    }
                }
            }

           stage('Trivy File Scan (Sequential)') {
            steps {
                dir('src/adservice') {
                    sh '''
                     docker run --rm \
                     -v $(pwd):/workspace \
                     -v $HOME/.m2:/root/.m2 \
                     aquasec/trivy:latest fs \
                     --scanners vuln \
                     --severity HIGH,CRITICAL \
                     --format table /workspace
                    '''
                }
            }        
        post {
            success {
                        echo "trivy security scanning successfully completed"
                    }
            failure {
                echo "Trivy scan detected HIGH/CRITICAL vulnerabilities!"
            }
          }
        }
      }
   }

        stage('Docker Build adservice') {
            steps {
                dir('src/adservice') {
                    sh 'docker build -t adservice:${BUILD_NUMBER} .'
                }
            }
        }

        stage('Trivy Image Scan') {
            steps {
                sh '''
                    docker run --rm \
                      -v /var/run/docker.sock:/var/run/docker.sock \
                      aquasec/trivy:latest image \
                      --severity HIGH,CRITICAL \
                      --format table \
                      adservice:${BUILD_NUMBER}
                '''
            }
            post {
                success {
                    echo "Trivy container image scan passed!"
                }
                failure {
                    echo "Trivy container scan detected vulnerabilities!"
                }
            }
        }

       stage('Push to Amazon ECR') {
            steps {
                withCredentials([
                    string(credentialsId: 'AWS_ACCESS_KEY_ID', variable: 'AWS_ACCESS_KEY_ID'),
                    string(credentialsId: 'AWS_SECRET_ACCESS_KEY', variable: 'AWS_SECRET_ACCESS_KEY')
                ]) {
                    sh '''
                        # AWS ECR Login
                        aws ecr get-login-password --region ${AWS_REGION} | docker login --username AWS --password-stdin ${ECR_URL}
                        
                        # Tag Images
                        docker tag ${IMAGE_NAME}:${BUILD_NUMBER} ${ECR_URL}/${IMAGE_NAME}:${BUILD_NUMBER}
                        docker tag ${IMAGE_NAME}:${BUILD_NUMBER} ${ECR_URL}/${IMAGE_NAME}:latest

                        # Push to ECR
                        docker push ${ECR_URL}/${IMAGE_NAME}:${BUILD_NUMBER}
                        docker push ${ECR_URL}/${IMAGE_NAME}:latest
                    '''
                }
            }
        }

        }

      post {
        always {
            sh """
                docker rmi ${IMAGE_NAME}:$BUILD_NUMBER} || true
                docker rmi ${ECR_URL}/${IMAGE_NAME}:${BUILD_NUMBER} || true
                docker rmi ${ECR_URL}/${IMAGE_NAME}:latest || true
            """
        }
        success {
            echo "Successfully pushed ${IMAGE_NAME} image to Amazon ECR!"
        }
        failure {
            echo "Pipeline failed! Please check logs."
        }
    }
}
