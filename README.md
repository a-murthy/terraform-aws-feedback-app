# Terraform AWS Feedback App No-Code Module

This module provisions the AWS App Runner compute layer for the Customer Feedback Board application. It exposes configuration parameters directly to the Developer Portal for Day 1 and Day 2 operations.

## Inputs
* `app_name`: Unique name for the application stack.
* `ai_enabled`: Toggles the Day 1 AI Sentiment Analyzer UI.
* `maintenance_mode`: Toggles the Day 2 Maintenance splash screen.

## Outputs
* `application_url`: The live public web address.
