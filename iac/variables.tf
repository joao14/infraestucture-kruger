# Región de AWS
variable "aws_region" {
  description = "Región de AWS donde se desplegará la infraestructura"
  type        = string
  default     = "us-west-2"
}

# ID de cuenta de AWS para ECR (puedes configurarlo si deseas automatizar el nombre de la imagen)
variable "aws_account_id" {
  description = "ID de cuenta de AWS para ECR"
  type        = string
}

# Nombre de la imagen ECR
variable "ecr_image" {
  description = "URI de la imagen ECR"
  type        = string
}

# Configuración de ECS
variable "ecs_memory" {
  description = "Memoria asignada a la tarea ECS"
  type        = string
  default     = "512"
}

variable "ecs_cpu" {
  description = "CPU asignado a la tarea ECS"
  type        = string
  default     = "256"
}

# Prefijo para nombres de recursos
variable "resource_prefix" {
  description = "Prefijo para nombres de recursos"
  type        = string
  default     = "app"
}
