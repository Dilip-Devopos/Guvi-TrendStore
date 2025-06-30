# 🚀 DevOps Project: Trend App Deployment on AWS EKS

🧠 Author: DilipKumar
📬 Email Notifications Enabled: dilipbca99@gmail.com

📚 Project Summary & CI/CD Workflow:

🧩 Project Overview:-
                  This project demonstrates end-to-end DevOps implementation by deploying a React-based application into a production-ready environment on AWS EKS using automated CI/CD pipelines. It integrates various industry-standard tools like Docker, Jenkins, Terraform, SonarQube, Trivy, Prometheus, and Grafana to handle everything from code build, scan, deployment, and monitoring.

🔁 CI/CD Pipeline Flow (Visual Summary)

Dev ➝ Git Commit ➝ GitHub Webhook
    ➝ Jenkins CI (CLone, sonarqube-Scan, security-Scan, Build-image, Push-image, Update YAML (file in github))
        ➝ Jenkins CD (Connect to EKS, Apply YAML)
            ➝ App Deployed to EKS (via LoadBalancer)
                ➝ Monitoring via Prometheus + Grafana

🔗 Repo links:

      GitHub Repo: https://github.com/Dilip-Devopos/Guvi-TrendStore.git
      DockerHub Image: https://hub.docker.com/repository/docker/kdilipkumar/trend
      
Validate Urls:-

        Jenkins url     : http://54.245.2.177:8080/
        Sonarqube url   : http://54.245.2.177:9000/projects
        Grafana url     : http://ae0d3fdc1cc994db187db180c0502abf-393301115.us-west-2.elb.amazonaws.com/dashboards
        Prometheus url  : http://affd41e4498f0407d9df8979564a579d-1629134265.us-west-2.elb.amazonaws.com:9090/service-discovery
        Application ARN : http://a663570b339364482a86a9e6f3445b69-1151892002.us-west-2.elb.amazonaws.com/

---

## 📌 Project Overview

- Application**: React frontend from [Guvi-TrendStore](https://github.com/Vennilavan12/Trend.git)
- Goal: Deploy the application to AWS EKS using a secure and automated DevOps pipeline
- Tools Used:
  - Docker, DockerHub
  - Terraform
  - Jenkins (CI/CD)
  - AWS EKS (Kubernetes)
  - SonarQube, Trivy, OWASP Dependency-Check
  - Prometheus, Grafana, Fluent Bit (Monitoring)

---

## 🛠️ Infrastructure Setup (Terraform)

**Resources Provisioned:**
- VPC & Subnet (CIDR: `198.168.0.0/24`)
- Internet Gateway & Route Table
- Security Group (Ports: 22, 8080)
- EC2 Instance for Jenkins (`t2.medium`, Ubuntu)
- Jenkins auto-installs via `user_data`

Access Jenkins:  
After provisioning:
http://54.245.2.177:8080/

Example Output (from `output.tf`):
hcl
output "jenkins_url" {
  value = "http://${aws_instance.jenkins_instance.public_ip}:8080"
}

🐳 Dockerization
Dockerfile Highlights:
Based on: public.ecr.aws/nginx/nginx:1.25
Serves React build output from /usr/share/nginx/html
Exposes port 80
CMD ["nginx", "-g", "daemon off;"]

🔁 CI Pipeline (Jenkins)

Pipeline #1: Build & Push

Stages:
     Clone Repo (Guvi-TrendStore)
    Static Code Analysis (SonarQube)
    Vulnerability Scanning:
    OWASP Dependency-Check
    Trivy Image Scan
    Docker Build & Push to DockerHub (kdilipkumar/trend:v<BUILD_NUMBER>)
    Auto-update deployment.yml with latest image tag

Push changes to GitHub:
    ✅ Triggered via Webhook
    ✅ Sends email notifications with scan reports

🚀 CD Pipeline (Jenkins)

Pipeline #2: Deploy to EKS

Stages:
     Clone GitHub repo
     Configure AWS CLI & connect to EKS cluster (trend-app)
Deploy:
     Deletes old deployment (if exists)
     Applies deployment.yml and service.yml
     Sends email notifications on success/failure

☸️ Kubernetes Setup (EKS):

Deployment:
       kind: Deployment
       name: trend-app-deployment
       replicas: 2
       image: kdilipkumar/trend:v(tag)
       Probes: Readiness and Liveness configured
       Resources: Requests and limits set for CPU and memory

       kubectl apply -f deployment.yml
       
Service:
      kind: Service
      name: trend-app-service
      type: LoadBalancer
      port: 80

      kubectl apply -f service.yml

📎 Access WebApp: 
      http://a663570b339364482a86a9e6f3445b69-1151892002.us-west-2.elb.amazonaws.com

📊 Monitoring & Observability:
Installed Stack:
       Prometheus
             http://affd41e4498f0407d9df8979564a579d-1629134265.us-west-2.elb.amazonaws.com:9090

        Grafana
            http://ae0d3fdc1cc994db187db180c0502abf-393301115.us-west-2.elb.amazonaws.com

         AWS Fluent Bit for CloudWatch
            Log Group:
                /aws/cluster/pod-logs

Monitors:

  Cluster health (CPU, Memory, Pods)
  App liveness/readiness probes
  Logs & alerting (Grafana dashboards)

📁 Project Structure:
Guvi-TrendStore/
│
├── deployment_pipeline/
│   ├── deployment.yml
│   └── service.yml
├── Jenkinsfile       (Build & Push)
|___ /dist
├── Jenkinsfile       (Deploy to EKS)
├── terraform/
│   ├── main.tf
│   ├── input.tf
│___└── output.tf

📷 Screenshots:
Add screenshots of:
Jenkins Job Console Output:

  ![image](https://github.com/user-attachments/assets/edffd27f-dbc2-425e-b4bd-e92dc0e97299)
  ![image](https://github.com/user-attachments/assets/a52ba746-2a6a-4934-b623-85904e1e78b5)
  ![image](https://github.com/user-attachments/assets/b14c292d-2614-4031-b87c-f88257bf32f0)

Sonarqube Dashboard:

  ![image](https://github.com/user-attachments/assets/214651d0-e3be-46a2-81e9-9e13b782c29f)

EKS Cluster Dashboard:

  ![image](https://github.com/user-attachments/assets/95d2e037-d811-4a97-a364-1a3415fb15ec)
      
LoadBalancer:

  ![image](https://github.com/user-attachments/assets/9b3060de-d4d8-4f93-9ab7-e28247dbb5a2)

CloudWatch:

  ![image](https://github.com/user-attachments/assets/34c5ef42-2e99-4135-a91e-8659778b1d4d)
  ![image](https://github.com/user-attachments/assets/d17b83da-c009-4ab1-8e5a-c7994e3b6245)

Email:    

  Success:
  ![image](https://github.com/user-attachments/assets/be999577-ddeb-43c1-8141-ad862474a483)

  Failuer
  ![image](https://github.com/user-attachments/assets/b25925ce-9905-4a32-96d7-32a886dfc5cc)

Grafana Dashboard:

  ![image](https://github.com/user-attachments/assets/ef41ead3-a9d6-4edc-b76a-4bb11266db65)
 
Prometheus Targets:

  ![image](https://github.com/user-attachments/assets/5642a4c9-17db-4cdf-b5f0-5d94ae5de424)

EC2 Machine cluster pods and service:

  ![image](https://github.com/user-attachments/assets/fc25ece4-fc37-4e60-a849-eb376123dd7b)  

Final deployed application:

  ![image](https://github.com/user-attachments/assets/45f06eca-8307-4325-a06f-ed871afe49cf)


✅ Final Status
✅ Fully Dockerized React App
✅ Automated CI/CD with Jenkins
✅ Deployed on AWS EKS
✅ Monitoring integrated with Prometheus & Grafana
✅ Security & Code Quality Scans Included
