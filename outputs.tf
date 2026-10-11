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
# 📋 PORTAL DEMO LINK (Fargate Dynamic Public IP Lookup Fixed)
# ==============================================================================

data "aws_network_interface" "fargate_ip_lookup" {
  filter {
    name   = "description"
    values = ["Attached to Elastic Network Interface created by ECS Fargate Task for family ${var.app_name}"]
  }

  # Blocks calculation until the Fargate service finishes cluster placement
  depends_on = [aws_ecs_service.app_service]
}

output "application_url" {
  description = "The live, public endpoint generated for your Customer Feedback Board application."
  # FIX: Added [0] index accessor to properly parse the underlying list of objects
  value       = "http://${data.aws_network_interface.fargate_ip_lookup.association[0].public_ip}:5000"
}

