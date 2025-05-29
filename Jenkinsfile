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
                    bat "docker run --name ${DOCKER_CONTAINER} -p 3000:3000 ${env.IMAGE_NAME}:${env.IMAGE_TAG}"
                    bat "npm test"
                    bat "docker stop ${DOCKER_CONTAINER}"
                }
            }
        }
        
    }

    post {
        always {
            bat "docker rmi ${env.IMAGE_NAME}:${env.IMAGE_TAG}"
        }
    }
}