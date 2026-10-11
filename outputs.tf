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
# 📋 PUBLIC PORTAL DEMO LINK (Extracts Actual Public Internet IP)
# ==============================================================================

data "aws_network_interface" "fargate_ip_lookup" {
  # Nativly uses AWS wildcards (*) to locate the exact network card for this app instance
  filter {
    name   = "description"
    values = ["*${var.app_name}*"]
  }

  filter {
    name   = "subnet-id"
    values = [aws_subnet.public_a.id]
  }

  depends_on = [time_sleep.wait_for_fargate_eni]
}

output "application_url" {
  description = "The live, public endpoint generated for your Customer Feedback Board application."
  # FIXED: Employs the precise [0] list index accessor to pull the public IP safely
  value       = "http://${data.aws_network_interface.fargate_ip_lookup.association[0].public_ip}:5000"
}
