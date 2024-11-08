# infraestucture-kruger
Solutions to get message from secrets manager using AWS

## 1. Start project

cd app
python -m venv venv
pip install -r requirements.txt
python app.py

## 2. Uppload infraestucture with Terraform

Para validar los recursos de terraform

cd iac

### a. Inicializar terraform en el projecto
terraform init
### b. Validate terraform
terraform validate 
### c. Validate execution plan
terraform plan
### d. Para aplicar los cambios
terraform apply 
