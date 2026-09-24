output "jenkins_instance_profile_name" { value = aws_iam_instance_profile.jenkins.name }
output "monitoring_instance_profile_name" { value = aws_iam_instance_profile.monitoring.name }
output "monitoring_instance_role_arn" { value = aws_iam_role.monitoring.arn }
output "eks_cluster_role_arn" { value = aws_iam_role.eks_cluster.arn }
output "eks_node_role_arn" { value = aws_iam_role.eks_nodes.arn }

output "eks_node_role_name" { value = aws_iam_role.eks_nodes.name }
