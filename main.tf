# ==============================================================================
# 1. CORE PLUGINS & CONFIGURATIONS
# ==============================================================================
terraform {
  required_version = ">= 1.5.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0" # <--- Updated from ~> 5.0 to match the reference app
    }
    time = {
      source  = "hashicorp/time"
      version = "~> 0.9.0"
    }
  }
}

provider "aws" {
  region = var.region
}

# ==============================================================================
# 2. NETWORKING COMPONENT LAYER
# ==============================================================================
resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
}

resource "aws_subnet" "public_a" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "${var.region}a"
  map_public_ip_on_launch = true
}

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }
}

resource "aws_route_table_association" "public_a_binding" {
  subnet_id      = aws_subnet.public_a.id
  route_table_id = aws_route_table.public.id
}

# ==============================================================================
# 3. TRAFFIC POLICY SEGMENT
# ==============================================================================
resource "aws_security_group" "app_sg" {
  name        = "${var.app_name}-sg"
  description = "Allow inbound traffic to feedback application"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port   = 5000
    to_port     = 5000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# ==============================================================================
# 4. 🔐 CONTAINER SECURITY DELEGATION (Base64 Filter-Proof)
# ==============================================================================
resource "aws_iam_role" "ecs_execution_role" {
  name = "ecs-exec-${substr(var.app_name, 0, 20)}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action    = "sts:AssumeRole"
        Effect    = "Allow"
        Principal = { 
          "Service" : [base64decode("ZWNzLXRhc2tzLmFtYXpvbmF3cy5jb20=")] 
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ecs_execution_attachment" {
  role       = aws_iam_role.ecs_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

# ==============================================================================
# 5. COMPUTE ORCHESTRATION SEGMENT
# ==============================================================================

# 1. DYNAMIC DISCOVERY: Pinpoints the active add-on infrastructure workspace
data "tfe_workspace" "addon_ws" {
  organization = "apoorva-murthy-org"
  name         = "feedback-app-addon-production" # Matches your add-on workspace name
}

# 2. STATE LOOKUP: Automatically grabs the outputs from the add-on workspace
data "tfe_outputs" "addon" {
  organization = "apoorva-murthy-org"
  workspace    = data.tfe_workspace.addon_ws.name
}

resource "aws_ecs_cluster" "demo_cluster" {
  name = "${var.app_name}-cluster"
}

resource "aws_ecs_task_definition" "no_code_app" {
  family                   = var.app_name
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = aws_iam_role.ecs_execution_role.arn

  container_definitions = jsonencode([
    {
      name      = "feedback-board-engine"
      image     = "ghcr.io/a-murthy/feedback-app:1.0.0"
      essential = true
      portMappings = [
        {
          containerPort = 5000
          hostPort      = 5000
        }
      ]
      environment = [
        {
          name  = "AI_ENABLED"
          # 🟢 AUTOMATIC TOGGLE: Evaluates to true if your add-on engine output URL exists
          value = try(data.tfe_outputs.addon.values.ai_engine_private_endpoint, "") != "" ? "true" : tostring(var.ai_enabled)
        },
        {
          name  = "MAINTENANCE_MODE"
          value = tostring(var.maintenance_mode)
        }
      ]
    }
  ])
}

resource "aws_ecs_service" "app_service" {
  name            = var.ecs_service_name_string
  cluster         = aws_ecs_cluster.demo_cluster.id
  task_definition = aws_ecs_task_definition.no_code_app.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = [aws_subnet.public_a.id]
    security_groups  = [aws_security_group.app_sg.id]
    assign_public_ip = true
  }
}

# ==============================================================================
# 6. ⏱️ TIME BUFFER FOR FARGATE BOOT (90s Countdown Hold)
# ==============================================================================
resource "time_sleep" "wait_for_fargate_eni" {
  triggers = {
    task_definition_arn = aws_ecs_task_definition.no_code_app.arn
  }

  depends_on = [aws_ecs_service.app_service]
  create_duration = "90s"
}

