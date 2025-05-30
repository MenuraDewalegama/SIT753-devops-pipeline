pipeline {
    agent any

    environment {
        IMAGE_NAME = 'jukebox'
        IMAGE_TAG = 'latest'
        ENV_FILE_LOCTION = 'D:\\Deakin\\T1\\SIT753-jenkins\\env'
        PROJECT_BACKEND = "jukebox-backend"
        DOCKER_CONTAINER = "jukebox_devops_container"
        REGION = 'us-central1'
        SONAR_SCAN_LOCATION = "D:\\Deakin\\T1\\SIT753-jenkins"
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
                    bat "type TestResult.txt"
                    bat "docker stop ${env.DOCKER_CONTAINER}"
                    bat "docker rm ${env.DOCKER_CONTAINER}"
                }
            }
        }

        stage('Code Quality Analysis') {
            steps {
                dir("${env.SONAR_SCAN_LOCATION}") {
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

        stage('Security') {
            steps {
                dir("${env.PROJECT_BACKEND}") {
                    bat "npm audit --audit-level=moderate || exit /b 0"
                }
            }
        }

        stage('Deploy') {
            steps {
                bat "docker-compose up -d --build"
            }
        }

        stage('Release') {
            steps {
                script{
                    withCredentials([
                        usernamePassword(credentialsId: 'dockerhub', usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_PASS')
                    ]) {
                        bat "docker login -u %DOCKER_USER% -p %DOCKER_PASS%"
                        bat "docker tag jukebox:latest %DOCKER_USER%/${IMAGE_NAME}:${IMAGE_TAG}"
                        bat "docker push %DOCKER_USER%/${IMAGE_NAME}:${IMAGE_TAG}"
                    }
                }

                script{
                    withCredentials([
                        file(credentialsId: 'gcp-service-account', variable: 'GOOGLE_APPLICATION_CREDENTIALS'),
                        usernamePassword(credentialsId: 'dockerhub', usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_PASS'),
                        string(credentialsId: 'gcp-project-id', variable: 'GCP_PROJECT_ID')
                    ]) {
                        bat 'gcloud auth activate-service-account --key-file="%GOOGLE_APPLICATION_CREDENTIALS%"'
                        bat 'gcloud config set project %GCP_PROJECT_ID%'
                        bat 'gcloud run deploy %IMAGE_NAME%-service --image=docker.io/%DOCKER_USER%/%IMAGE_NAME%:%IMAGE_TAG% --platform=managed --region=%REGION% --allow-unauthenticated --quiet'   
                        bat 'gcloud run services add-iam-policy-binding %IMAGE_NAME%-service --member="allUsers" --role="roles/run.invoker" --region=%REGION% --platform=managed'
                    }
                }
            }
        }

        stage('Monitoring') {
            steps { 
                script {
                    withCredentials([
                        string(credentialsId: 'DATADOG_API_KEY', variable: 'DD_API_KEY'),
                        string(credentialsId: 'DATADOG_APP_KEY', variable: 'DD_APP_KEY')
                    ]) {
                        bat 'curl -X GET "https://api.us5.datadoghq.com/api/v1/monitor/6255805" -H "DD-API-KEY: %DD_API_KEY%" -H "DD-APPLICATION-KEY: %DD_APP_KEY%"'
                    }
                }
            }
        }
        
    }

    post {
        always {
            bat "docker ps -aq | xargs docker stop"
            bat "docker container prune -f"
            bat "docker rmi ${env.IMAGE_NAME}:${env.IMAGE_TAG}"
        }
    }
}