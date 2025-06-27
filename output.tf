output "jenkins_url" {
  description = "The URL of the Jenkins server"
  value       = "http://${aws_instance.jenkins_instance.public_ip}:8080"

}
