# ==============================================================================
# STANDARD REUSABLE BLUEPRINT OUTPUTS
# ==============================================================================

output "container_image" {
  description = "The verified target runtime engine URI consumed by the compute cluster."
  value       = "public.ecr.aws/hashicorp-education/customer-feedback-app:1.0.0"
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
# 📋 REFERENCE-REPLICATED PORTAL LINK
# ==============================================================================

data "aws_network_interfaces" "app_eni" {
  filter {
    name   = "group-id"
    values = [aws_security_group.app_sg.id]
  }

  filter {
    name   = "status"
    values = ["in-use"]
  }
  
  depends_on = [time_sleep.wait_for_fargate_eni]
}

locals {
  has_active_eni   = length(data.aws_network_interfaces.app_eni.ids) > 0
  extracted_eni_id = local.has_active_eni ? element(sort(data.aws_network_interfaces.app_eni.ids), 0) : null
}

data "aws_network_interface" "fargate_ip_lookup" {
  id = local.extracted_eni_id != null ? local.extracted_eni_id : "eni-00000000000000000"
}

output "application_url" {
  description = "The live, public endpoint generated for your Customer Feedback Board application."
  value       = local.has_active_eni && try(data.aws_network_interface.fargate_ip_lookup.association[0].public_ip, "") != "" ? "http://${data.aws_network_interface.fargate_ip_lookup.association[0].public_ip}:5000" : "PENDING_AWS_NETWORK_ATTACHMENT"
}
