output "vpc_id" { value = aws_vpc.this.id }
output "public_subnet_ids" { value = aws_subnet.public[*].id }
output "private_subnet_ids" { value = aws_subnet.private[*].id }
output "database_subnet_ids" { value = aws_subnet.database[*].id }
output "jenkins_security_group_id" { value = aws_security_group.jenkins.id }
output "monitoring_security_group_id" { value = aws_security_group.monitoring.id }
output "rds_security_group_id" { value = aws_security_group.rds.id }
output "eks_node_security_group_id" { value = aws_security_group.eks_nodes.id }
