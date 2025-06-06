provider "aws" {
  region = "us-east-1"
  default_tags {
    tags = {
      environment            = ""
      application_cc         = ""
      application_id         = ""
      application            = ""
      vice_presidency        = ""
      area                   = ""
      buss_owner             = ""
      map-migrated           = ""
      application_name       = ""
      application_tech_owner = ""
    }
  }
}
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "= 5.84.0"
    }
  }
}
