output "jenkins_sg_id" {
  value = aws_security_group.jenkins.id
}

output "monitoring_sg_id" {
  value = aws_security_group.monitoring.id
}

output "eks_node_sg_id" {
  value = aws_security_group.eks_node.id
}

output "rds_sg_id" {
  value = aws_security_group.rds.id
}
