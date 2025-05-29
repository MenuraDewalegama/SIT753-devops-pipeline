pipeline {
    agent any

    environment {
        IMAGE_NAME = 'jukebox'
        IMAGE_TAG = 'latest'
        ENV_FILE_LOCTION = 'D:\\Deakin\\T1\\SIT753-jenkins\\env'
        PROJECT_BACKEND = "jukebox-backend"
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
                    bat "npm install"
                    bat "npm run dev"
                    bat "npm test"
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