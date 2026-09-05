# Estas variables NO tienen valores por defecto a proposito -- se llenan
# en terraform.tfvars, un archivo que NUNCA se sube a Git (esta en .gitignore).

variable "aiven_api_token" {
  description = "Token personal de la API de Aiven"
  type        = string
  sensitive   = true
}

variable "aiven_project" {
  description = "Nombre del proyecto en Aiven donde vive el servicio"
  type        = string
}
