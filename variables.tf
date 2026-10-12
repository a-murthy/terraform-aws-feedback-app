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
  # FIX: Bumps the resource namespace string to clear the AWS naming collision loop
  default = "feedback-app-service"
}

variable "container_image_uri" {
  description = "The target public ECR image repository path utilized for the deployment container runtime"
  type        = string
  default     = "public.ecr.aws/platform-engineering-demos/feedback-app:v1"
}
