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

            stage('sonarqube analysis') {
                steps {
                    echo "===== stage 4: sonarcloud analysis ====="
                    withSonarQubeEnv('SonarQube-Server') {
                        dir('src/adservice') {
                            sh 'mvn sonar:sonar'
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


        }
}
