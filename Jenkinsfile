pipeline {
    agent any

    environment {
        IMAGE_NAME = 'jukebox'
        IMAGE_TAG = 'latest'
        ENV_FILE_LOCTION = 'D:\\Deakin\\T1\\SIT753-jenkins\\env'
        PROJECT_BACKEND = "jukebox-backend"
        DOCKER_CONTAINER = "jukebox_devops_container"
        REGION='us-central1'
    }

    stages {

        // stage('Checkout') {
        //     steps {
        //         git branch: 'master', url: 'https://github.com/MenuraDewalegama/SIT753-devops-pipeline.git'
        //     }
        // }

        // stage('Build') {
        //     steps {
        //         bat "copy /Y ${env.ENV_FILE_LOCTION}\\.env ${env.PROJECT_BACKEND}"
        //         bat "docker build -t ${env.IMAGE_NAME}:${env.IMAGE_TAG} ."
        //     }
        // }

        // stage('Test') {
        //     steps {
        //         dir("${env.PROJECT_BACKEND}") {
        //             bat "docker run -d --name ${DOCKER_CONTAINER} -p 3000:3000 ${env.IMAGE_NAME}:${env.IMAGE_TAG}"
        //             bat "npm install"
        //             bat "npm test || exit /b 0"
        //             bat "docker stop ${env.DOCKER_CONTAINER}"
        //             bat "docker rm ${env.DOCKER_CONTAINER}"
        //         }
        //     }
        // }

        // stage('Code Quality Analysis') {
        //     steps {
                
        //         script {
        //             bat """
        //                 powershell -Command Invoke-WebRequest -Uri https://binaries.sonarsource.com/Distribution/sonar-scanner-cli/sonar-scanner-cli-5.0.1.3006-windows.zip -OutFile sonar-scanner-cli-5.0.1.3006-windows.zip
        //                 powershell -Command Expand-Archive -Path sonar-scanner-cli-5.0.1.3006-windows.zip -DestinationPath .
        //             """
        //         }
                
        //         script{
        //             withCredentials([
        //                 string(credentialsId: 'SONAR_TOKEN', variable: 'SONAR_TOKEN')
        //             ]) {
        //                 bat '''
        //                 sonar-scanner-5.0.1.3006-windows\\bin\\sonar-scanner.bat

        //             '''
        //             }
        //         }
                
        //     }
        // }

        // stage('Security') {
        //     steps {
        //         dir("${env.PROJECT_BACKEND}") {
        //             bat "npm audit --audit-level=moderate || exit /b 0"
        //         }
        //     }
        // }

        // stage('Deploy') {
        //     steps {
        //         bat "docker-compose up -d --build"
        //     }
        // }

        // stage('Release') {
        //     steps {
        //         script{
        //             withCredentials([
        //                 usernamePassword(credentialsId: 'dockerhub', usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_PASS')
        //             ]) {
        //                 bat "docker login -u %DOCKER_USER% -p %DOCKER_PASS%"
        //                 bat "docker push %DOCKER_USER%/${IMAGE_NAME}:${IMAGE_TAG}"
        //             }
        //         }

        //         script{
        //             withCredentials([
        //                 file(credentialsId: 'gcp-service-account', variable: 'GOOGLE_APPLICATION_CREDENTIALS'),
        //                 usernamePassword(credentialsId: 'dockerhub', usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_PASS'),
        //                 string(credentialsId: 'gcp-project-id', variable: 'GCP_PROJECT_ID')
        //             ]) {
        //                 bat 'gcloud auth activate-service-account --key-file="%GOOGLE_APPLICATION_CREDENTIALS%"'
        //                 bat 'gcloud config set project %GCP_PROJECT_ID%'
        //                 bat 'gcloud run deploy %IMAGE_NAME%-service --image=docker.io/%DOCKER_USER%/%IMAGE_NAME%:%IMAGE_TAG% --platform=managed --region=%REGION% --allow-unauthenticated --quiet'   
        //                 bat 'gcloud run services add-iam-policy-binding %IMAGE_NAME%-service --member="allUsers" --role="roles/run.invoker" --region=%REGION% --platform=managed'
        //             }
        //         }
        //     }
        // }

        stage('Monitoring') {
            steps {
                script {
                    withCredentials([
                        string(credentialsId: 'DATADOG_API_KEY', variable: 'DD_API_KEY'),
                        string(credentialsId: 'DATADOG_APP_KEY', variable: 'DD_APP_KEY')
                    ]) {

                        def monitorJson = """
                            {
                            "name": "Cloud Run Error Monitor",
                            "type": "metric alert",
                            "query": "avg(last_5m):avg:cloud.run.error_count{service:${IMAGE_NAME}-service,region:${REGION}} > 0",
                            "message": "Errors detected on ${IMAGE_NAME}-service in GCP. Immediate attention required.",
                            "tags": ["env:prod", "service:${IMAGE_NAME}", "source:jenkins"],
                            "options": {
                                "thresholds": {
                                "critical": 0
                                },
                                "notify_audit": false,
                                "locked": false,
                                "timeout_h": 0,
                                "include_tags": true,
                                "require_full_window": true,
                                "new_host_delay": 300,
                                "notify_no_data": false
                            }
                            }
                        """
                        writeFile file: 'cloudrun_monitor.json', text: monitorJson

                        bat 'curl -s -H "DD-API-KEY: %DD_API_KEY%" -H "DD-APPLICATION-KEY: %DD_APP_KEY%" https://api.datadoghq.com/api/v1/monitor -d @cloudrun_monitor.json'
                    }
                }
            }
        }
        
    }

    // post {
    //     always {
    //         bat "docker rmi ${env.IMAGE_NAME}:${env.IMAGE_TAG}"
    //     }
    // }
}