pipeline {
    agent any

    environment {
        IMAGE_NAME = 'jukebox'
        IMAGE_TAG = 'latest'
    }

    stages {

        stage('Checkout') {
            steps {
                git branch: 'master', url: 'https://github.com/MenuraDewalegama/SIT753-devops-pipeline.git'
            }
        }

        stage('Build') {
            steps {
                bat "docker build -t ${env.IMAGE_NAME}:${env.IMAGE_TAG} ."
            }
        }

        stage('Test') {
            steps {
                dir("jukebox-backend") {
                    bat "npm install"
                    bat "npm start"
                    bat "npm test"
                }
            }
        }
        
    }
}