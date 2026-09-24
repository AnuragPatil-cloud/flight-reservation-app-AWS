output "instance_id" { value = aws_db_instance.this.id }
output "endpoint" { value = aws_db_instance.this.address }
output "port" { value = aws_db_instance.this.port }
output "database_name" { value = aws_db_instance.this.db_name }
output "arn" { value = aws_db_instance.this.arn }
