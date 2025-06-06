### Outputs del módulo AWS Glue Jobs ###
output "glue_job_names" {
  description = "Nombres de los AWS Glue Jobs creados"
  value       = [for job in aws_glue_job.jobs : job.name]
}

output "glue_job_arns" {
  description = "ARNs de los AWS Glue Jobs creados"
  value       = [for job in aws_glue_job.jobs : job.arn]
}

output "glue_job_role_name" {
  description = "Nombre del rol IAM creado para los Glue Jobs"
  value       = aws_iam_role.glue_job_role.name
}

output "glue_job_role_arn" {
  description = "ARN del rol IAM creado para los Glue Jobs"
  value       = aws_iam_role.glue_job_role.arn
}

output "glue_job_security_group_id" {
  description = "ID del grupo de seguridad creado para los Glue Jobs (si se especificó una VPC)"
  value       = var.vpc_id != "" ? aws_security_group.glue_job_sg[0].id : null
}

output "glue_job_policy_arn" {
  description = "ARN de la política IAM creada para los Glue Jobs"
  value       = aws_iam_policy.glue_job_policy.arn
}

output "glue_triggers" {
  description = "Desencadenadores de Glue creados"
  value       = { for trigger in aws_glue_trigger.job_triggers : trigger.name => trigger.id }
}

output "security_configuration_id" {
  description = "ID de la configuración de seguridad de Glue (si se creó)"
  value       = var.create_security_configuration ? aws_glue_security_configuration.this[0].id : null
}