# ==============================================================================
# STANDARD REUSABLE BLUEPRINT OUTPUTS
# ==============================================================================

output "container_image" {
  description = "The verified target runtime engine URI consumed by the compute cluster."
  value       = var.verified_image_path_uri
}

output "ecs_cluster_name" {
  description = "The target execution cluster housing the Fargate system engine."
  value       = aws_ecs_cluster.demo_cluster.name
}

output "ecs_service_name" {
  description = "The runtime orchestrator supervising the application availability state."
  value       = var.ecs_service_name_string
}

output "subnet_id" {
  description = "The isolated VPC networking node assigned to this no-code service footprint."
  value       = aws_subnet.public_a.id
}

# ==============================================================================
# 📋 IMMUTABLE STATIC PORTAL LINK (Bypasses Data Filter Lookups Completely)
# ==============================================================================

output "application_url" {
  description = "The live, public endpoint generated for your Customer Feedback Board application."
  value       = "http://${aws_eip.nlb_eip.public_ip}:5000"
}
