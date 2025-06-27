pipeline {
    agent {
        docker {
            image 'kdilipkumar/jenkins-agent:v19'
            args '--user root -v /var/run/docker.sock:/var/run/docker.sock -v /mnt/data/dep-check-data:/mnt/data/dep-check-data'
        }
    }

    environment {
        DOCKER_IMAGE = "kdilipkumar/trend:v${BUILD_NUMBER}"
    }

    stages {
        stage('Cleanup') {
            steps {
                sh 'rm -rf Guvi-TrendStore || true'
            }
        }

        stage('Clone Repository') {
            steps {
                sh '''
                    echo "Cloning repository..."
                    git clone https://github.com/Dilip-Devopos/Guvi-TrendStore.git
                '''
            }
        }   

        stage('Static Code Analysis') {
            environment {
                SONAR_URL = "http://54.245.2.177:9000"
            }
            steps {
                withCredentials([string(credentialsId: 'sonarqube', variable: 'SONAR_AUTH_TOKEN')]) {
                    sh '''
                        cd Guvi-TrendStore
                        sonar-scanner -Dsonar.projectKey=Guvi-TrendStore -Dsonar.sources=. -Dsonar.host.url=${SONAR_URL} -Dsonar.login=${SONAR_AUTH_TOKEN}
                    '''
                }
            }    
        }

        stage('OWASP Dependency-Check Vulnerabilities') {
            steps {
                script {
                    sh '''
                        mkdir -p dependency-check-reports
                        /opt/dependency-check/bin/dependency-check.sh \
                        --project "Guvi-TrendStore" \
                        --scan Guvi-TrendStore \
                        --out dependency-check-reports \
                        --format "ALL" \
                        --data /mnt/data/dep-check-data
                    '''
                    sh 'chown -R jenkins:jenkins dependency-check-reports'
                    sh 'chmod 644 dependency-check-reports/*.xml'
                    sh 'ls -la dependency-check-reports'
                }
                dependencyCheckPublisher pattern: 'dependency-check-reports/*.xml'
            }
        }

        stage('Build Docker Image') {
            environment {
                DOCKERFILE_LOCATION = "Guvi-TrendStore/Dockerfile"
            }
            steps {
                script {
                    sh 'cd Guvi-TrendStore && docker build -t ${DOCKER_IMAGE} .'
                }
            }
        }
        
        stage('Security Scan with Trivy') {
            steps {
                script {
                    sh '''
                        echo "Running Trivy vulnerability scan..."
                        trivy --version
                        trivy image --severity HIGH,CRITICAL --format table -o trivy-report.html ${DOCKER_IMAGE}
                    '''
                }
            }
        }

        stage('Push Docker Image') {
            environment {
                REGISTRY_CREDENTIALS = credentials('docker-cred')
            }
            steps {
                script {
                    def dockerImage = docker.image("${DOCKER_IMAGE}")
                    docker.withRegistry('https://index.docker.io/v1/', "docker-cred") {
                        dockerImage.push()
                    }
                }
            }
        }

        stage('Update K8S manifest & push to Repo') {
            steps {
                withCredentials([usernamePassword(
                    credentialsId: 'fef7e074-f534-481f-88fb-91e677c88be9', 
                    usernameVariable: 'GIT_USERNAME', 
                    passwordVariable: 'GIT_PASSWORD'
                )]) {
                    sh '''
                        echo "Cloning manifest repo..."
                        git clone https://${GIT_USERNAME}:${GIT_PASSWORD}@github.com/Dilip-Devopos/Guvi-TrendStore.git
                        cd Guvi-TrendStore

                        echo "Updating image tag in deployment.yml..."
                        sed -i "s|image: kdilipkumar/trend:.*|image: kdilipkumar/trend:${BUILD_NUMBER}|" deployment.yml
                        cat deploy.yaml

                        git config user.email "jenkins@gamil.com"
                        git config user.name "Jenkins CI"

                        git add deployment.yml
                        git commit -m "Updated image tag to v${BUILD_NUMBER} via Jenkins pipeline"
                        git push origin main
                    '''
                }
            }
        }
    }

    post {
        success {
            emailext(
                subject: "SUCCESS: Job '${env.JOB_NAME} [${env.BUILD_NUMBER}]'",
                body: "Good news!\n\nThe Jenkins job '${env.JOB_NAME}' completed successfully.\nBuild URL: ${env.BUILD_URL}",
                to: "dilipbca99@gmail.com",
                attachmentsPattern: "trivy-report.html,dependency-check-reports/dependency-check-report.html"
            )
        }

        failure {
            emailext(
                subject: "FAILURE: Job '${env.JOB_NAME} [${env.BUILD_NUMBER}]'",
                body: "Unfortunately, the Jenkins job '${env.JOB_NAME}' has failed.\nBuild URL: ${env.BUILD_URL}",
                to: "dilipbca99@gmail.com"
            )
        }
    }
}
