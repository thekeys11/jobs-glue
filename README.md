# AWS Glue Jobs Terraform Module

Este módulo permite desplegar múltiples AWS Glue Jobs con configuraciones de seguridad, roles IAM con permisos de mínimo privilegio y opciones de personalización avanzadas.

## Características

- Creación de múltiples AWS Glue Jobs con una sola configuración.
- Amplia configuración de default_arguments para cada Glue Job, permitiendo personalización detallada de los parámetros del script.
- Configuración de seguridad con cifrado KMS para datos en reposo y tránsito.
- Rol IAM con política de permisos robusta que incluye:
    - Acceso a servicios glue, s3, ec2, iam, cloudwatch, cloudtrail, lakeformation.
    - Permisos específicos para operaciones S3 en buckets designados (scripts, datos, temporales, y buckets específicos de la solución como ban-useast1-dev-edlh-raw-bucket, pca-analized-2248, etc.).
    - Permisos iam:PassRole para que Glue pueda asumir otros roles.
    - Permisos de creación y eliminación de tags en recursos EC2 relevantes para Glue.**
- Soporte para desencadenadores (triggers) programados y condicionales con definición explícita de condiciones de éxito/fallo de jobs previos.
- Configuración de red opcional (VPC, subredes, grupo de seguridad).
- Personalización completa de propiedades de los jobs (tipo de trabajador, número de trabajadores, timeouts, reintentos, etc.).
- Implementación de mejores prácticas de seguridad.

## Requisitos

| Nombre    | Versión  |
| --------- | -------- |
| terraform | >= 1.0.0 |
| aws       | >= 4.0.0 |

## Uso

```hcl
glue_jobs = [
  {
    name                = "etl-job-pca-anlized"
    glue_version        = "4.0"
    worker_type         = "G.1X"
    number_of_workers   = 10
    timeout             = 60
    max_retries         = 1
    command_name        = "glueetl"
    script_location     = "solicitar a william"
    python_version      = "3"
    job_bookmark_option = "job-bookmark-enable"
    default_arguments = {
      "--source_database" = "source_db"
      "--target_path"     = "s3://my-data-processing-bucket/raw/"
      "--enable-metrics"  = "true"
      "--conf"            = "spark.driver.memory=5g"
      # Nuevas características para etl-job-pca-anlized
      "--additional-python-modules" = "langchain==0.3.2,langchain_aws==0.2.2"
      "--database_name"             = "pca_ce"
      "--llm_model_id"              = "anthropic.claude-3-5-sonnet-20240620-v1:0"
      "--s3_output_parquet"         = "s3://ban-useast1-dev-pca-out-818667456472-b/pca_parquet_results/pca-procesed-basics/"
      "--s3_output_query"           = "s3://ban-useast1-dev-pca-out-818667456472-b/athena-queries/"
      "--table_basic"               = "tbl_pca_analyzed_basics"
      "--table_name"                = "parsedfiles"
      "--topics_table_name"         = "s3://ban-useast1-dev-pca-out-818667456472-b/pca-support-files/Topics.csv"
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
    script_location     = "solicitar a william"
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
      "--batch_size"                = "50"
      "--database_name"             = "pca_ce"
      "--limit_query"               = "2000"
      "--nlp_table_name"            = "tbl_pca_analyzed_nlp"
      "--raw_table_name"            = "rawfilesanalytics"
      "--s3_agent_names"            = "s3://ban-useast1-dev-pca-out-818667456472-b/pca-support-files/AgentNames.csv"
      "--s3_agent_words"            = "s3://ban-useast1-dev-pca-out-818667456472-b/pca-support-files/AgentSearchWords.csv"
      "--s3_output_error_log"       = "https://ban-useast1-dev-pca-out-818667456472-b/pca_parquet_results/pca-procesed-nlp/logs/" 
      # Verifica si es S3 o HTTPS
      "--s3_output_md"              = "s3://ban-useast1-dev-pca-out-818667456472-b/pca-procesed-mds/md_agent/"
      "--s3_output_parquet"         = "s3://ban-useast1-dev-pca-out-818667456472-b/pca_parquet_results/pca-procesed-nlp/parquet_files/"
      "--s3_output_query"           = "s3://ban-useast1-dev-pca-out-818667456472-b/athena-queries/"
      "--similarity_threshold"      = "90"
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
    script_location     = "solicitar a william"
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
      "--batch_size": "100",
      "--database_name": "pca_ce",
      "--limit_query": "500",
      "--llm_model_id": "anthropic.claude-3-5-sonnet-20240620-v1:0",
      "--llm_table_name": "tbl_pca_analyzed_llm",
      "--raw_table_name": "rawfilesanalytics",
      "--s3_agent_names": "s3://ban-useast1-dev-pca-out-818667456472-b/pca-support-files/AgentNames.csv",
      "--s3_output_error_log": "s3://ban-useast1-dev-pca-out-818667456472-b/pca_parquet_results/pca-procesed-llm/logs/",
      "--s3_output_md": "s3://ban-useast1-dev-pca-out-818667456472-b/pca-procesed-mds/md_full/",
      "--s3_output_parquet": "s3://ban-useast1-dev-pca-out-818667456472-b/pca_parquet_results/pca-procesed-llm/parquet_files/",
      "--s3_output_query": "s3://ban-useast1-dev-pca-out-818667456472-b/athena-queries/",
      "--similarity_threshold": "70"
    }
    tags = {
      DataFlow = "pca"
      Stage    = "extract"
    }
  }
]

  # Configuración de desencadenadores (opcional)
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
```

## Variables de Entrada

| Nombre                        | Descripción                                                                                         | Tipo         | Valor por defecto | Requerido |
| ----------------------------- | --------------------------------------------------------------------------------------------------- | ------------ | ----------------- | --------- |
| region                    | AWS region donde se desplegarán los recursos                                                    | string       | -                 | sí        |
| account_id                    | ID de la cuenta de AWS                                                                              | string       | -                 | sí        |
| prefix                        | Prefijo para nombrar los recursos                                                                   | string       | "glue"            | no        |
| glue_job_role_name            | Nombre del rol IAM para los Glue Jobs                                                               | string       | "GlueJobRole"     | no        |
| s3_script_bucket              | Nombre del bucket S3 donde se almacenan los scripts de Glue                                         | string       | -                 | sí        |
| s3_data_bucket                | Nombre del bucket S3 donde se almacenan los datos                                                   | string       | -                 | sí        |
| s3_temp_dir                   | Ruta S3 para los archivos temporales de Glue                                                        | string       | -                 | sí        |
| vpc_id                        | ID de la VPC para la configuración de red (opcional)                                                | string       | ""                | no        |
| subnet_ids                    | Lista de IDs de subnets para la configuración de red (opcional)                                     | list(string) | []                | no        |
| security_configuration        | Nombre de la configuración de seguridad de Glue existente (opcional)                                | string       | ""                | no        |
| kms_key_arn                   | ARN de la clave KMS para encriptación (opcional)                                                    | string       | ""                | no        |
| create_security_configuration | Indica si se debe crear una configuración de seguridad                                              | bool         | false             | no        |
| allow_all_resources           | Si es true, permite acceso a todos los recursos en la política IAM (no recomendado para producción) | bool         | false             | no        |
| common_tags                   | Tags comunes para todos los recursos                                                                | map(string)  | {}                | no        |
| glue_jobs                     | Lista de configuraciones de Glue Jobs a crear                                                       | list(object) | -                 | sí        |
| job_triggers                  | Lista de desencadenadores para los Glue Jobs (opcional)                                             | list(object) | []                | no        |

## Outputs

| Nombre                     | Descripción                                                                    |
| -------------------------- | ------------------------------------------------------------------------------ |
| glue_job_names             | Nombres de los AWS Glue Jobs creados                                           |
| glue_job_arns              | ARNs de los AWS Glue Jobs creados                                              |
| glue_job_role_name         | Nombre del rol IAM creado para los Glue Jobs                                   |
| glue_job_role_arn          | ARN del rol IAM creado para los Glue Jobs                                      |
| glue_job_security_group_id | ID del grupo de seguridad creado para los Glue Jobs (si se especificó una VPC) |
| glue_job_policy_arn        | ARN de la política IAM creada para los Glue Jobs                               |
| glue_triggers              | Desencadenadores de Glue creados                                               |
| security_configuration_id  | ID de la configuración de seguridad de Glue (si se creó)                       |

## Mejores Prácticas de Seguridad Implementadas

1. **Mínimo privilegio**: Los roles IAM se crean con permisos mínimos necesarios para ejecutar los jobs, siguiendo las políticas detalladas de AWS Glue, EC2, S3, IAM, CloudWatch y LakeFormation.
2. **Cifrado de datos**: Opción para crear configuración de seguridad con cifrado KMS para datos en reposo y datos de marcadores de trabajo.
3. **Acceso restringido a recursos específicos**: Configuración para acceder solo a los buckets S3 necesarios y a los que se interactúa explícitamente en los scripts.
4. **Seguridad en red**: SSoporte para despliegue en VPC con grupos de seguridad dedicados y la creación de interfaces de red necesarias para Glue.
5. **Etiquetado consistente**: Tags obligatorios para facilitar la administración y el control de costos de los recursos.
6. **Configuración de reintento limitado**: Previene ciclos de error infinitos con número máximo de reintentos configurable.

## Notas

- Asegúrese de que los buckets S3 referenciados (incluyendo los especificados en los argumentos de los jobs) existan antes de aplicar este módulo.
- Las claves KMS deben existir y tener las políticas adecuadas para ser utilizadas por Glue.
- Para conexiones a bases de datos (definidas en connections), asegúrese de crear primero las conexiones en el AWS Glue Console o mediante otro módulo de Terraform.
- Los job_names en la configuración de job_triggers deben coincidir exactamente con los nombres de los jobs definidos en glue_jobs (el módulo añade automáticamente el prefijo).


## Importante
Este módulo de Glue fue creado por **Escala24x7**.

Si necesitas apoyo o tienes alguna consulta sobre este módulo, no dudes en contactarnos.