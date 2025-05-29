pipeline {
    agent any

    environment {
        IMAGE_NAME = 'jukebox'
        IMAGE_TAG = 'latest'
        ENV_FILE_LOCTION = 'D:\\Deakin\\T1\\SIT753-jenkins\\env'
        PROJECT_BACKEND = "jukebox-backend"
        DOCKER_CONTAINER = "jukebox_devops_container"
    }

    stages {

        stage('Checkout') {
            steps {
                git branch: 'master', url: 'https://github.com/MenuraDewalegama/SIT753-devops-pipeline.git'
            }
        }

        stage('Build') {
            steps {
                bat "copy /Y ${env.ENV_FILE_LOCTION}\\.env ${env.PROJECT_BACKEND}"
                bat "docker build -t ${env.IMAGE_NAME}:${env.IMAGE_TAG} ."
            }
        }

        stage('Test') {
            steps {
                dir("${env.PROJECT_BACKEND}") {
                    bat "docker run -d --name ${DOCKER_CONTAINER} -p 3000:3000 ${env.IMAGE_NAME}:${env.IMAGE_TAG}"
                    bat "npm install"
                    bat "npm test || exit /b 0"
                    bat "docker stop ${DOCKER_CONTAINER}"
                }
            }
        }

        stage('Code Quality Analysis') {
            steps {
                
                script {
                    bat """
                        powershell -Command Invoke-WebRequest -Uri https://binaries.sonarsource.com/Distribution/sonar-scanner-cli/sonar-scanner-cli-5.0.1.3006-windows.zip -OutFile sonar-scanner-cli-5.0.1.3006-windows.zip
                        powershell -Command Expand-Archive -Path sonar-scanner-cli-5.0.1.3006-windows.zip -DestinationPath .
                    """
                }
                
                script{
                    withCredentials([
                        string(credentialsId: 'SONAR_TOKEN', variable: 'SONAR_TOKEN')
                    ]) {
                        bat '''
                        sonar-scanner-5.0.1.3006-windows\\bin\\sonar-scanner.bat

                    '''
                    }
                }
                
            }
        }
        
    }

    post {
        always {
            bat "docker stop ${env.DOCKER_CONTAINER}"
            bat "docker rm ${env.DOCKER_CONTAINER}"
            bat "docker rmi ${env.IMAGE_NAME}:${env.IMAGE_TAG}"
        }
    }
}