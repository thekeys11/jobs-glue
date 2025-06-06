provider "aws" {
  region = "us-east-1"
  default_tags {
    tags = {
      environment      = "dev"
      application_cc   = "5101960070"
      application_id   = "2248-000"
      application      = "2248-000"
      vice_presidency  = "vpe_mercadeo_canales_y_experiencia_de_cliente"
      area             = "centro_de_servicio_al_cliente"
      buss_owner       = "eduardo_del_valle"
      map-migrated     = "migNY782LEQKE"
      application_name = "post_call_analytics"
      application_tech_owner = "efraim_casas"
    }
  }
}

terraform {
  cloud {
    organization = "banesco-pa-IaC"
    workspaces {
      name = "ban-wktf-dev-data-2257-pca-workload"
    }
  }
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "= 5.84.0"
    }
  }
}