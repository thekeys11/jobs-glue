### Variables globales ###
variable "region" {
  description = "AWS region donde se desplegarán los recursos"
  type        = string
}

variable "account_id" {
  description = "ID de la cuenta de AWS"
  type        = string
}

variable "prefix" {
  description = "Prefijo para nombrar los recursos"
  type        = string
  default     = "glue"
}

### variables AWS Glue Jobs ###

variable "glue_job_role_name" {
  description = "Nombre del rol IAM para los Glue Jobs"
  type        = string
  default     = "GlueJobRole"
}

variable "s3_script_bucket" {
  description = "Nombre del bucket S3 donde se almacenan los scripts de Glue"
  type        = string
}

variable "s3_data_bucket" {
  description = "Nombre del bucket S3 donde se almacenan los datos"
  type        = string
}

variable "s3_temp_dir" {
  description = "Ruta S3 para los archivos temporales de Glue"
  type        = string
}

variable "vpc_id" {
  description = "ID de la VPC para la configuración de red (opcional)"
  type        = string
  default     = ""
}

variable "subnet_ids" {
  description = "Lista de IDs de subnets para la configuración de red (opcional)"
  type        = list(string)
  default     = []
}

variable "security_configuration" {
  description = "Nombre de la configuración de seguridad de Glue existente (opcional)"
  type        = string
  default     = ""
}

variable "kms_key_arn" {
  description = "ARN de la clave KMS para encriptación (opcional)"
  type        = string
  default     = ""
}

variable "create_security_configuration" {
  description = "Indica si se debe crear una configuración de seguridad"
  type        = bool
  default     = false
}

variable "allow_all_resources" {
  description = "Si es true, permite acceso a todos los recursos en la política IAM (no recomendado para producción)"
  type        = bool
  default     = false
}

variable "common_tags" {
  description = "Tags comunes para todos los recursos"
  type        = map(string)
  default     = {}
}

variable "glue_jobs" {
  description = "Lista de configuraciones de Glue Jobs a crear"
  type = list(object({
    name                = string
    glue_version        = string
    worker_type         = string
    number_of_workers   = number
    timeout             = number
    max_retries         = number
    command_name        = string
    script_location     = string
    python_version      = string
    job_bookmark_option = string
    max_concurrent_runs = optional(number)
    notify_delay_after  = optional(number)
    connections         = optional(list(string), [])
    default_arguments   = optional(map(string), {})
    tags                = optional(map(string), {})
  }))
}

variable "job_triggers" {
  description = "Lista de desencadenadores para los Glue Jobs (opcional)"
  type = list(object({
    name      = string
    type      = string
    schedule  = optional(string)
    enabled   = bool
    job_names = list(string)
    timeout   = optional(number)
    conditions       = optional(list(object({
      job_name     = string
      state        = string # "SUCCEEDED", "FAILED", "STOPPED", "TIMEOUT"
      crawler_name = optional(string)
      crawl_state  = optional(string)
    })), [])
  }))
  default = []
}