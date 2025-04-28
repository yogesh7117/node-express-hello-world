pipeline {
    agent any

    environment {
        DOCKERHUB_CREDENTIALS = 'dockerhub-creds'
        IMAGE_NAME = 'yogeshpri/nodeimgg'
    }

    stages {
        stage('Checkout Code') {
            steps {
                checkout scm
            }
        }

        stage('Build and Push Docker Image') {
            when {
                branch 'master'
            }
            stages {
                stage('Build Docker Image') {
                    steps {
                        sh 'docker build -t $IMAGE_NAME:$BUILD_NUMBER .'
                    }
                }

                stage('Login to DockerHub') {
                    steps {
                        withCredentials([usernamePassword(credentialsId: "${DOCKERHUB_CREDENTIALS}", usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_PASS')]) {
                            sh 'echo $DOCKER_PASS | docker login -u $DOCKER_USER --password-stdin'
                        }
                    }
                }

                stage('Push Docker Image') {
                    steps {
                        sh '''
                            docker tag $IMAGE_NAME:$BUILD_NUMBER $IMAGE_NAME:latest
                            docker push $IMAGE_NAME:$BUILD_NUMBER
                            docker push $IMAGE_NAME:latest
                        '''
                    }
                }

                stage('Deploy to Kubernetes') {
                    steps {
                        sh '''
                            kubectl apply -f deployment.yaml
                            kubectl apply -f services.yaml
                        '''
                    }
                }
            }
        }
    }

    post {
        always {
            cleanWs()
        }
    }
}
