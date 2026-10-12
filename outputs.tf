# ==============================================================================
# STANDARD REUSABLE BLUEPRINT OUTPUTS
# ==============================================================================

output "container_image" {
  description = "The verified target runtime engine URI consumed by the compute cluster."
  value       = "public.ecr.aws/platform-engineering-demos/customer-feedback-app:1.0.0"
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
# 📋 REFERENCE-ALIGNED DEMO LINK (Fixed Timer Dependency Loop)
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

  # REFERENCE STRATEGY: Forces the network lookup to halt until the 90s sleep clock finishes
  filter {
    name   = "description"
    values = ["Attached to Elastic Network Interface created by ECS Fargate Task*", time_sleep.wait_for_fargate_eni.id != "" ? "Attached to Elastic Network Interface created by ECS Fargate Task*" : ""]
  }

  depends_on = [time_sleep.wait_for_fargate_eni]
}

output "application_url" {
  description = "The live, public endpoint generated for your Customer Feedback Board application."
  value       = "http://${data.aws_network_interface.fargate_ip_lookup.association[0].public_ip}:5000"
}
