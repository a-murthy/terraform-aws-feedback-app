variable "region" {
  description = "The AWS region to deploy resources into"
  type        = string
  default     = "us-east-1"
}

variable "app_name" {
  description = "Name layout utilized across resource resource labeling"
  type        = string
}

variable "ai_enabled" {
  description = "Portal dynamic parameter controlling the AI badge visualization state"
  type        = string
  default     = "false"
}

variable "maintenance_mode" {
  description = "Portal operational parameter executing immediate app routing lockout"
  type        = string
  default     = "false"
}

variable "ecs_service_name_string" {
  type    = string
  default = "feedback-app-service"
}

# Add this simple optional input variable to your main app variables.tf
variable "ai_endpoint_url" {
  type        = string
  default     = ""  # 🟢 Safe fallback: defaults to empty if the addon isn't there
  description = "Dynamic injection token holding the live Day 1 Lambda API URL."
}

