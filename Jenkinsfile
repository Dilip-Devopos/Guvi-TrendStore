pipeline {
    agent {
        docker {
            image 'kdilipkumar/jenkins-agent:v19'
            args '--user root -v /var/run/docker.sock:/var/run/docker.sock -v /var/jenkins_home/dep-check-data:/usr/share/dependency-check/data'
        }
    }

    environment {
        IMAGE_NAME = "guvi-project-1"
        VERSION = "${env.BUILD_NUMBER}"
        REGISTRY_CREDENTIALS = credentials('docker-cred')
    }

    stages {
        stage('Cleanup') {
            steps {
                sh 'rm -rf Guvi-Project-1 || true'
            }
        }

        stage('Clone Repository') {
            steps {
                sh '''
                    echo "Cloning repository..."
                    git clone https://github.com/Dilip-Devopos/Guvi-Project-1.git
                '''
            }
        }

        stage('Static Code Analysis') {
            environment {
                SONAR_URL = "http://18.61.24.207:9000"
            }
            steps {
                withCredentials([string(credentialsId: 'sonarqube', variable: 'SONAR_AUTH_TOKEN')]) {
                    sh '''
                        cd Guvi-Project-1
                        sonar-scanner -Dsonar.projectKey=Guvi-Project-1-prod -Dsonar.sources=. -Dsonar.host.url=${SONAR_URL} -Dsonar.login=${SONAR_AUTH_TOKEN}
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
                        --project "Guvi-Project-1" \
                        --scan Guvi-Project-1 \
                        --out dependency-check-reports \
                        --format "ALL" \
                        --data /usr/share/dependency-check/data
                    '''
                    sh 'chown -R jenkins:jenkins dependency-check-reports'
                    sh 'chmod 644 dependency-check-reports/*.xml'
                    sh 'ls -la dependency-check-reports'
                }
                dependencyCheckPublisher pattern: 'dependency-check-reports/*.xml'
            }
        }

        stage('Build & Tag') {
            steps {
                dir('Guvi-Project-1') {
                    sh "./build.sh ${IMAGE_NAME} ${VERSION} ${BRANCH_NAME}"
                }
            }
        }
        
        stage('Prepare Docker Image Name') {
            steps {
                script {
                    def repo = (env.BRANCH_NAME == "main") ? "kdilipkumar/prod" : "kdilipkumar/dev"
                    env.dockerimage = "${repo}:${VERSION}"
                }
            }
        }
        
        stage('Security Scan with Trivy') {
            steps {
                script {
                    sh '''
                        echo "Running Trivy vulnerability scan..."
                        trivy --version
                        trivy image --severity HIGH,CRITICAL --format table -o trivy-report.html ${dockerimage}
                    '''
                }
            }
        }

        stage('Push to Docker Hub') {
            steps {
                script {
                    def repo = (env.BRANCH_NAME == "main") ? "kdilipkumar/prod" : "kdilipkumar/dev"
                    def dockerimage = "${repo}:${VERSION}"

                    docker.withRegistry('https://index.docker.io/v1/', 'docker-cred') {
                        sh "docker push ${dockerimage}"
                    }
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

