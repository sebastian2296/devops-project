# AWS Variables
variable "aws_region" {
    description = "La región de AWS"
    default     = "us-east-1"
}

# Custom Variables
variable "owner" {
    description = "Dueño de la app"
}

variable "app" {
    description   = "Nombre de la app"
    default       = "proyecto-final" 
}

variable "number_instances" {
    description = "Número de instancias a crear"
    type        = number
    default     = 2
}

variable "database_username" {
    description   = "Usuario de la base de datos"
    default       = "admin"
    sensitive  = true 
}

variable "database_password" {
    description   = "Contraseña de la base de datos"
    sensitive  = true 
}

variable "public_key" {
    description = "Llave pública"
    sensitive   = true
}

variable "ami_id" {
    description = "ID de la AMI"
    default     = "ami-05fa00d4c63e32376"
}

# Remote State networking
variable "tf_state_bucket_networking" {
    description = "Nombre del bucket donde se guarda el tf state de networking"
    type        = string
}

