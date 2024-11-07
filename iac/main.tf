# Cargar el archivo provider.tf
provider "aws" {
  region = var.aws_region
}

# 1. Crear una VPC
resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "${var.resource_prefix}-vpc"
  }
}

# 2. Crear una Subred Pública
resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "${var.aws_region}a"
  map_public_ip_on_launch = true
  tags = {
    Name = "${var.resource_prefix}-public-subnet"
  }
}

# 3. Crear un Internet Gateway para la VPC
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "${var.resource_prefix}-gateway"
  }
}

# 4. Crear una tabla de ruteo para la subred pública
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }

  tags = {
    Name = "${var.resource_prefix}-public-route-table"
  }
}

# Asociar la tabla de ruteo con la subred pública
resource "aws_route_table_association" "public_association" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}

# 5. Crear un Security Group para ECS
resource "aws_security_group" "ecs_sg" {
  name        = "${var.resource_prefix}-ecs-sg"
  vpc_id      = aws_vpc.main.id
  description = "Allow HTTP traffic"

  # Permitir tráfico HTTP
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Permitir tráfico de salida
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.resource_prefix}-ecs-security-group"
  }
}

# 6. Crear el secreto en AWS Secrets Manager
resource "aws_secretsmanager_secret" "app_secret" {
  name        = "${var.resource_prefix}-app-message"
  description = "Mensaje encriptado para la aplicación"
}

# Crear una versión del secreto con el mensaje "Buenos días, Ecuador"
resource "aws_secretsmanager_secret_version" "app_secret_version" {
  secret_id     = aws_secretsmanager_secret.app_secret.id
  secret_string = "{\"MESSAGE\": \"Buenos días, Ecuador\"}"
}

# 7. Crear un bucket S3 para almacenar los logs
resource "aws_s3_bucket" "app_logs" {
  bucket = "${var.resource_prefix}-logs-bucket"
  acl    = "private"

  tags = {
    Name = "${var.resource_prefix}-logs"
  }
}

# Configurar la política del bucket para permitir escritura de logs
resource "aws_s3_bucket_policy" "app_logs_policy" {
  bucket = aws_s3_bucket.app_logs.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect   = "Allow",
        Action   = ["s3:PutObject"],
        Resource = "${aws_s3_bucket.app_logs.arn}/*",
        Principal = "*"
      }
    ]
  })
}

# Importar el archivo `ecs.tf` (contiene el clúster ECS, el rol IAM, la definición de tarea y el servicio)
module "ecs" {
  source = "./ecs"
}
