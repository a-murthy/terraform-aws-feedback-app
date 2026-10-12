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
  value       = var.ecs_service_name_string
}

output "subnet_id" {
  description = "The isolated VPC networking node assigned to this no-code service footprint."
  value       = aws_subnet.public_a.id
}

# ==============================================================================
# 📋 NO-CONSOLE PORTAL DEMO LINK (Fargate Dynamic Public IP Lookup Fixed)
# ==============================================================================

data "aws_network_interface" "fargate_ip_lookup" {
  filter {
    name   = "group-id"
    values = [aws_security_group.app_sg.id]
  }

  filter {
    name   = "subnet-id"
    values = [aws_subnet.public_a.id]
  }

  depends_on = [time_sleep.wait_for_fargate_eni]
}

output "application_url" {
  description = "The live, public endpoint generated for your Customer Feedback Board application."
  # CRITICAL FIX: Explicit array index accessor restored to match provider specifications
  value       = "http://${data.aws_network_interface.fargate_ip_lookup.association[0].public_ip}:5000"
}
