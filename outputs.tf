# ==============================================================================
# STANDARD REUSABLE BLUEPRINT OUTPUTS
# ==============================================================================

output "container_image" {
  description = "The verified target runtime engine URI consumed by the compute cluster."
  value       = "ghcr.io/a-murthy/feedback-app:1.0.2"
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

output "target_security_group_id" {
  description = "The primary firewall profile ensuring line-of-sight network connectivity."
  value       = aws_security_group.app_sg.id
}

# ==============================================================================
# 📋 REFERENCE-ALIGNED PORTAL LINK DISCOVERY ENGINE (Syntax Validated)
# ==============================================================================

output "application_url" {
  description = "The live, public endpoint generated for your Customer Feedback Board application."
  # 🟢 FIXED: Corrected the bracket typo and aligned the evaluation boundaries with your reference app
  value       = local.has_active_eni && try(data.aws_network_interface.fargate_ip_lookup.association[0].public_ip, "") != "" ? "http://${data.aws_network_interface.fargate_ip_lookup.association[0].public_ip}:5000" : "PENDING_AWS_NETWORK_ATTACHMENT"
}
