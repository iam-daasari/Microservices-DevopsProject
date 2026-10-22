pipeline {
    agent any

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
}
