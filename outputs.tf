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
# 📋 PUBLIC PORTAL DEMO LINK (Clean Tag Querying Isolation Loop)
# ==============================================================================

data "aws_network_interface" "fargate_ip_lookup" {
  # FIX: Queries the managed service name tag directly to avoid any string mismatches
  filter {
    name   = "tag:aws:ecs:serviceName"
    values = [aws_ecs_service.app_service.name]
  }

  depends_on = [time_sleep.wait_for_fargate_eni]
}

output "application_url" {
  description = "The live, public endpoint generated for your Customer Feedback Board application."
  # FIXED: Employs the array position element lookup syntax to extract the raw IP
  value       = "http://${data.aws_network_interface.fargate_ip_lookup.association[0].public_ip}:5000"
}
