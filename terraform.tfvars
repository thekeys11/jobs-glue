### variables globales ###
region     = "us-east-1"
account_id = "560787199965"
prefix     = "data-pipeline"

### Configuración de almacenamiento ###
s3_script_bucket = "my-glue-scripts-bucket-pca"
s3_data_bucket   = "my-data-processing-bucket-pca"
s3_temp_dir      = "my-glue-scripts-bucket-pca/temp"

### Roles y permisos ###
glue_job_role_name  = "DataPipelineGlueJobRole"
allow_all_resources = false #Recomendado para producción: false

### Configuración de seguridad ###
create_security_configuration = true
kms_key_arn                   = "arn:aws:kms:us-east-1:560787199965:key/251f0bbe-c8ce-4c22-8e5a-1ccc126160f2"

# VPC (opcional, eliminar o comentar si no se requiere)
# vpc_id     = "vpc-0123456789abcdef0"
# subnet_ids = ["subnet-0123456789abcdef0", "subnet-0123456789abcdef1"]

### Tags comunes ###
common_tags = {
  Environment = "dev"
  Project     = "post_call_analytics"
  Owner       = "efraim-casas"
  Terraform   = "true"
}

### Definición de los AWS Glue Jobs ###
glue_jobs = [
  {
    name                = "etl-job-pca-anlized"
    glue_version        = "4.0"
    worker_type         = "G.1X"
    number_of_workers   = 10
    timeout             = 60
    max_retries         = 1
    command_name        = "glueetl"
    script_location     = "https://my-glue-scripts-bucket-pca.s3.us-east-1.amazonaws.com/etl-job-pca-anlized.py" #"git::https://banesco-cloudbpa@dev.azure.com/banesco-cloudbpa/ban-data-2248-pca-app/_git/ban-aws-repo-data-2248-pca-backend-001/glue-etls/scripts/etl-job-pca-anlized.py"
    python_version      = "3"
    job_bookmark_option = "job-bookmark-enable"
    default_arguments = {
      "--source_database" = "source_db"
      "--target_path"     = "s3://my-data-processing-bucket/raw/"
      "--enable-metrics"  = "true"
      "--conf"            = "spark.driver.memory=5g"
      # Nuevas características para etl-job-pca-anlized
      "--additional-python-modules" = "langchain==0.3.2,langchain_aws==0.2.2"
      # "--database_name"             = "pca_ce"
      # "--llm_model_id"              = "anthropic.claude-3-5-sonnet-20240620-v1:0"
      # "--s3_output_parquet"         = "s3://ban-useast1-dev-pca-out-818667456472-b/pca_parquet_results/pca-procesed-basics/"
      # "--s3_output_query"           = "s3://ban-useast1-dev-pca-out-818667456472-b/athena-queries/"
      # "--table_basic"               = "tbl_pca_analyzed_basics"
      # "--table_name"                = "parsedfiles"
      # "--topics_table_name"         = "s3://ban-useast1-dev-pca-out-818667456472-b/pca-support-files/Topics.csv"
    }
    tags = {
      DataFlow = "pca"
      Stage    = "extract"
    }
  },
  {
    name                = "etl-job-generate-fuzzy-nlp"
    glue_version        = "4.0"
    worker_type         = "G.1X"
    number_of_workers   = 10
    timeout             = 90
    max_retries         = 2
    command_name        = "glueetl"
    script_location     = "https://my-glue-scripts-bucket-pca.s3.us-east-1.amazonaws.com/etl-job-generate-fuzzy-nlp.py" #git::https://banesco-cloudbpa@dev.azure.com/banesco-cloudbpa/ban-data-2248-pca-app/_git/ban-aws-repo-data-2248-pca-backend-001/glue-etls/scripts/etl-job-generate-fuzzy-nlp.py"
    python_version      = "3"
    job_bookmark_option = "job-bookmark-enable"
    max_concurrent_runs = 1
    default_arguments = {
      "--source_path"    = "s3://my-data-processing-bucket/raw/"
      "--target_path"    = "s3://my-data-processing-bucket/transformed/"
      "--enable-metrics" = "true"
      "--conf"           = "spark.driver.memory=5g"
      # Nuevas características para etl-job-generate-fuzzy-nlp
      "--additional-python-modules" = "markdown==3.7,fuzzywuzzy==0.18.0"
      # "--batch_size"                = "50"
      # "--database_name"             = "pca_ce"
      # "--limit_query"               = "2000"
      # "--nlp_table_name"            = "tbl_pca_analyzed_nlp"
      # "--raw_table_name"            = "rawfilesanalytics"
      # "--s3_agent_names"            = "s3://ban-useast1-dev-pca-out-818667456472-b/pca-support-files/AgentNames.csv"
      # "--s3_agent_words"            = "s3://ban-useast1-dev-pca-out-818667456472-b/pca-support-files/AgentSearchWords.csv"
      # "--s3_output_error_log"       = "https://ban-useast1-dev-pca-out-818667456472-b/pca_parquet_results/pca-procesed-nlp/logs/)" # Verifica si es S3 o HTTPS
      # "--s3_output_md"              = "s3://ban-useast1-dev-pca-out-818667456472-b/pca-procesed-mds/md_agent/"
      # "--s3_output_parquet"         = "s3://ban-useast1-dev-pca-out-818667456472-b/pca_parquet_results/pca-procesed-nlp/parquet_files/"
      # "--s3_output_query"           = "s3://ban-useast1-dev-pca-out-818667456472-b/athena-queries/"
      # "--similarity_threshold"      = "90"
    }
    tags = {
      DataFlow = "pca"
      Stage    = "extract"
    }
  },
  {
    name                = "etl-job-generate-llm_v2"
    glue_version        = "4.0"
    worker_type         = "G.1X"
    number_of_workers   = 10
    timeout             = 60
    max_retries         = 1
    command_name        = "glueetl"
    script_location     = "https://my-glue-scripts-bucket-pca.s3.us-east-1.amazonaws.com/etl-job-generate-llm_v2.py" #"git::https://banesco-cloudbpa@dev.azure.com/banesco-cloudbpa/ban-data-2248-pca-app/_git/ban-aws-repo-data-2248-pca-backend-001git::https://banesco-cloudbpa@dev.azure.com/banesco-cloudbpa/ban-data-2248-pca-app/_git/ban-aws-repo-data-2248-pca-backend-001/glue-etls/scripts/etl-job-generate-fuzzy-nlp.py"
    python_version      = "3"
    job_bookmark_option = "job-bookmark-enable"
    connections         = ["redshift-connection"]
    default_arguments = {
      "--source_path"     = "s3://my-data-processing-bucket/transformed/"
      "--redshift_schema" = "analytics"
      "--enable-metrics"  = "true"
      "--conf"            = "spark.driver.memory=5g"
      # Nuevas características para etl-job-generate-llm_v2
      "--additional-python-modules": "langchain==0.3.2,markdown==3.7,langchain_aws==0.2.2,fuzzywuzzy==0.18.0",
      # "--batch_size": "100",
      # "--database_name": "pca_ce",
      # "--limit_query": "500",
      # "--llm_model_id": "anthropic.claude-3-5-sonnet-20240620-v1:0",
      # "--llm_table_name": "tbl_pca_analyzed_llm",
      # "--raw_table_name": "rawfilesanalytics",
      # "--s3_agent_names": "s3://ban-useast1-dev-pca-out-818667456472-b/pca-support-files/AgentNames.csv",
      # "--s3_output_error_log": "s3://ban-useast1-dev-pca-out-818667456472-b/pca_parquet_results/pca-procesed-llm/logs/",
      # "--s3_output_md": "s3://ban-useast1-dev-pca-out-818667456472-b/pca-procesed-mds/md_full/",
      # "--s3_output_parquet": "s3://ban-useast1-dev-pca-out-818667456472-b/pca_parquet_results/pca-procesed-llm/parquet_files/",
      # "--s3_output_query": "s3://ban-useast1-dev-pca-out-818667456472-b/athena-queries/",
      # "--similarity_threshold": "70"
    }
    tags = {
      DataFlow = "pca"
      Stage    = "extract"
    }
  }
]

### Desencadenadores (opcional) ###
job_triggers = [
  {
    name      = "daily-pca-anlized-job" # Nombre descriptivo para el trigger programado
    type      = "SCHEDULED"
    schedule  = "cron(0 1 * * ? *)" # Se ejecuta diariamente a la 1:00 AM UTC
    enabled   = true
    job_names = ["etl-job-pca-anlized"] # ¡IMPORTANTE! Debe coincidir con el 'name' de tu Glue Job.
    timeout   = 120
    # Los triggers SCHEDULED no necesitan conditions
  },
  {
    name      = "transform-fuzzy-nlp-after-pca" # Nombre descriptivo para el trigger condicional
    type      = "CONDITIONAL"
    enabled   = true
    job_names = ["etl-job-generate-fuzzy-nlp"] #IMPORTANTE Debe coincidir con el 'name' de tu Glue Job.
    timeout   = 120
    conditions = [
      {
        job_name = "etl-job-pca-anlized" # El nombre del job que debe completarse primero
        state    = "SUCCEEDED"           # La condición: el job anterior debe haber sido exitoso
      }
    ]
  },
  {
    name      = "load-llm-v2-after-fuzzy-nlp" # Nombre descriptivo para el trigger condicional
    type      = "CONDITIONAL"
    enabled   = true
    job_names = ["etl-job-generate-llm_v2"]
    timeout   = 60
    conditions = [
      {
        job_name = "etl-job-generate-fuzzy-nlp" # El nombre del job que debe completarse primero
        state    = "SUCCEEDED"                # La condición: el job anterior debe haber sido exitoso
      }
    ]
  }
]