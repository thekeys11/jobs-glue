module "glue_jobs" {
  source = "./modules/glue-jobs" 
  region           = var.region
  account_id       = var.account_id
  prefix           = var.prefix
  s3_script_bucket = var.s3_script_bucket
  s3_data_bucket   = var.s3_data_bucket
  s3_temp_dir      = var.s3_temp_dir
  glue_jobs        = var.glue_jobs
  job_triggers     = var.job_triggers
}