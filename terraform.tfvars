### variables globales ###
region     = "us-east-1"
account_id = ""
prefix     = "data-pipeline"

### Configuración de almacenamiento ###
s3_script_bucket = "my-glue-scripts-bucket"
s3_data_bucket   = "my-data-processing-bucket"
s3_temp_dir      = "my-glue-scripts-bucket/temp"

### Roles y permisos ###
glue_job_role_name  = "DataPipelineGlueJobRole"
allow_all_resources = false #Recomendado para producción: false

### Configuración de seguridad ###
create_security_configuration = true
kms_key_arn                   = "arn:aws:kms:us-east-1:ìdcuenta:key/tukey"

# VPC (opcional, eliminar o comentar si no se requiere)
# vpc_id     = "tu-vpc"
# subnet_ids = ["tu-subnet", "tu-subnet2"]

### Tags comunes ###
common_tags = {
  Environment = "tu-environment"
  Project     = ""
  Owner       = ""
  Terraform   = "true"
}

### Definición de los AWS Glue Jobs ###
glue_jobs = [
  {
    name                = ""
    glue_version        = "4.0"
    worker_type         = "G.1X"
    number_of_workers   = 10
    timeout             = 60
    max_retries         = 1
    command_name        = "glueetl"
    script_location     = ""
    python_version      = "3"
    job_bookmark_option = "job-bookmark-enable"
    default_arguments = {
      "--source_database" = "source_db"
      "--target_path"     = "s3://my-data-processing-bucket/raw/"
      "--enable-metrics"  = "true"
      "--conf"            = "spark.driver.memory=5g"
      # Nuevas características
      "--additional-python-modules" = "langchain==0.3.2,langchain_aws==0.2.2"
      # "--database_name"             = ""
      # "--llm_model_id"              = "anthropic.claude-3-5-sonnet-20240620-v1:0"
      # "--s3_output_parquet"         = ""
      # "--s3_output_query"           = ""
      # "--table_basic"               = "tbl_pca_analyzed_basics"
      # "--table_name"                = "parsedfiles"
      # "--topics_table_name"         = ""
    }
    tags = {
      DataFlow = ""
      Stage    = "extract"
    }
  },
  {
    name                = ""
    glue_version        = "4.0"
    worker_type         = "G.1X"
    number_of_workers   = 10
    timeout             = 90
    max_retries         = 2
    command_name        = "glueetl"
    script_location     = ""
    python_version      = "3"
    job_bookmark_option = "job-bookmark-enable"
    max_concurrent_runs = 1
    default_arguments = {
      "--source_path"    = ""
      "--target_path"    = ""
      "--enable-metrics" = "true"
      "--conf"           = "spark.driver.memory=5g"
      # Nuevas características
      "--additional-python-modules" = "markdown==3.7,fuzzywuzzy==0.18.0"
      # "--batch_size"                = "50"
      # "--database_name"             = ""
      # "--limit_query"               = "2000"
      # "--nlp_table_name"            = ""
      # "--raw_table_name"            = "rawfilesanalytics"
      # "--s3_agent_names"            = ""
      # "--s3_agent_words"            = ""
      # "--s3_output_error_log"       = "" Verifica si es S3 o HTTPS
      # "--s3_output_md"              = ""
      # "--s3_output_parquet"         = ""
      # "--s3_output_query"           = ""
      # "--similarity_threshold"      = "90"
    }
    tags = {
      DataFlow = ""
      Stage    = "extract"
    }
  },
  {
    name                = ""
    glue_version        = "4.0"
    worker_type         = "G.1X"
    number_of_workers   = 10
    timeout             = 60
    max_retries         = 1
    command_name        = "glueetl"
    script_location     = ""
    python_version      = "3"
    job_bookmark_option = "job-bookmark-enable"
    connections         = ["redshift-connection"]
    default_arguments = {
      "--source_path"     = ""
      "--redshift_schema" = ""
      "--enable-metrics"  = "true"
      "--conf"            = "spark.driver.memory=5g"
      # Nuevas características
      "--additional-python-modules": "langchain==0.3.2,markdown==3.7,langchain_aws==0.2.2,fuzzywuzzy==0.18.0",
      # "--batch_size": "100",
      # "--database_name": "",
      # "--limit_query": "500",
      # "--llm_model_id": "anthropic.claude-3-5-sonnet-20240620-v1:0",
      # "--llm_table_name": "",
      # "--raw_table_name": "rawfilesanalytics",
      # "--s3_agent_names": "",
      # "--s3_output_error_log": "",
      # "--s3_output_md": "",
      # "--s3_output_parquet": "",
      # "--s3_output_query": "",
      # "--similarity_threshold": "70"
    }
    tags = {
      DataFlow = ""
      Stage    = "extract"
    }
  }
]

### Desencadenadores (opcional) ###
job_triggers = [
  {
    name      = "" # Nombre descriptivo para el trigger programado
    type      = "SCHEDULED"
    schedule  = "cron(0 1 * * ? *)" # Se ejecuta diariamente a la 1:00 AM UTC
    enabled   = true
    job_names = [""] # ¡IMPORTANTE! Debe coincidir con el 'name' de tu Glue Job.
    timeout   = 120
    # Los triggers SCHEDULED no necesitan conditions
  },
  {
    name      = "" # Nombre descriptivo para el trigger condicional
    type      = "CONDITIONAL"
    enabled   = true
    job_names = [""] #IMPORTANTE Debe coincidir con el 'name' de tu Glue Job.
    timeout   = 120
    conditions = [
      {
        job_name = "" # El nombre del job que debe completarse primero
        state    = "SUCCEEDED"           # La condición: el job anterior debe haber sido exitoso
      }
    ]
  },
  {
    name      = "" # Nombre descriptivo para el trigger condicional
    type      = "CONDITIONAL"
    enabled   = true
    job_names = [""]
    timeout   = 60
    conditions = [
      {
        job_name = "" # El nombre del job que debe completarse primero
        state    = "SUCCEEDED"                # La condición: el job anterior debe haber sido exitoso
      }
    ]
  }
]
