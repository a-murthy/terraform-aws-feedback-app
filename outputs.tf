# ==============================================================================
# STANDARD REUSABLE BLUEPRINT OUTPUTS
# ==============================================================================

output "container_image" {
  description = "The verified target runtime engine URI consumed by the compute cluster."
  value       = "public.ecr.aws/platform-engineering-demos/feedback-app:latest"
}

output "ecs_cluster_name" {
  description = "The target execution cluster housing the Fargate system engine."
  value       = aws_ecs_cluster.demo_cluster.name
}

output "ecs_service_name" {
  description = "The runtime orchestrator supervising the application availability state."
  value       = aws_ecs_service.app_service.name
}

output "subnet_id" {
  description = "The isolated VPC networking node assigned to this no-code service footprint."
  value       = aws_subnet.public_a.id
}

# ==============================================================================
# 📋 NO-DATA-SOURCE PORTAL DEMO LINK (Clean Service Map References)
# ==============================================================================

output "application_url" {
  description = "The live, public endpoint generated for your Customer Feedback Board application."
  # Reads the primary public entry endpoint straight from your managed service network block
  value       = "http://${aws_ecs_service.app_service.name}.${var.app_name}.local:5000"
}
