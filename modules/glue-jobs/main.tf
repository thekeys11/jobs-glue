### AWS Glue Jobs Module ###
# Crear el rol IAM para los Glue Jobs con permisos mínimos necesarios
resource "aws_iam_role" "glue_job_role" {
  name = var.glue_job_role_name

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "glue.amazonaws.com"
        }
      }
    ]
  })

  tags = merge(
    var.common_tags,
    {
      Name = var.glue_job_role_name
    }
  )
}

# Política de permisos para el rol de Glue
# resource "aws_iam_policy" "glue_job_policy" {
#   name        = "${var.glue_job_role_name}-policy"
#   description = "Policy for Glue Jobs with least privilege access"

#   policy = jsonencode({
#     Version = "2012-10-17"
#     Statement = [
#       {
#         Action = [
#           "glue:*",
#           "s3:GetBucketLocation",
#           "s3:ListBucket",
#           "s3:ListAllMyBuckets",
#           "s3:GetBucketAcl",
#           "ec2:DescribeVpcEndpoints",
#           "ec2:DescribeRouteTables",
#           "ec2:CreateNetworkInterface",
#           "ec2:DeleteNetworkInterface",
#           "ec2:DescribeNetworkInterfaces",
#           "ec2:DescribeSecurityGroups",
#           "ec2:DescribeSubnets",
#           "ec2:DescribeVpcAttribute",
#           "iam:ListRolePolicies",
#           "iam:GetRole",
#           "iam:GetRolePolicy",
#           "cloudwatch:PutMetricData"
#         ]
#         Effect = "Allow"
#         Resource = var.allow_all_resources ? "*" : [
#           "arn:aws:s3:::${var.s3_script_bucket}/*",
#           "arn:aws:s3:::${var.s3_script_bucket}",
#           "arn:aws:s3:::${var.s3_data_bucket}/*",
#           "arn:aws:s3:::${var.s3_data_bucket}",
#           "arn:aws:logs:${var.region}:${var.account_id}:log-group:/aws-glue/jobs/*",
#           "arn:aws:cloudwatch:${var.region}:${var.account_id}:*"
#         ]
#       }
#     ]
#   })
# }

resource "aws_iam_policy" "glue_job_policy" {
  name        = "${var.glue_job_role_name}-policy"
  description = "Policy for Glue Jobs with comprehensive access"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "glue:*",
          "s3:GetBucketLocation",
          "s3:ListBucket",
          "s3:ListAllMyBuckets",
          "s3:GetBucketAcl",
          "ec2:DescribeVpcEndpoints",
          "ec2:DescribeRouteTables",
          "ec2:CreateNetworkInterface",
          "ec2:DeleteNetworkInterface",
          "ec2:DescribeNetworkInterfaces",
          "ec2:DescribeSecurityGroups",
          "ec2:DescribeSubnets",
          "ec2:DescribeVpcAttribute",
          "iam:ListRolePolicies",
          "iam:GetRole",
          "iam:GetRolePolicy",
          "cloudwatch:PutMetricData"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "s3:CreateBucket"
        ]
        Resource = [
          "arn:aws:s3:::aws-glue-*"
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject"
        ]
        Resource = [
          "arn:aws:s3:::aws-glue-*/*",
          "arn:aws:s3:::*/*aws-glue-*/*"
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject"
        ]
        Resource = [
          "arn:aws:s3:::crawler-public*",
          "arn:aws:s3:::aws-glue-*"
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = [
          "arn:aws:logs:*:*:*:/aws-glue/*"
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "ec2:CreateTags",
          "ec2:DeleteTags"
        ]
        Condition = {
          "ForAllValues:StringEquals": {
            "aws:TagKeys": [
              "aws-glue-service-resource"
            ]
          }
        }
        Resource = [
          "arn:aws:ec2:*:*:network-interface/*",
          "arn:aws:ec2:*:*:security-group/*",
          "arn:aws:ec2:*:*:instance/*"
        ]
      },
      {
        Sid = "AWSLakeFormationDataAdminAllow"
        Effect = "Allow"
        Action = [
          "lakeformation:*",
          "cloudtrail:DescribeTrails",
          "cloudtrail:LookupEvents",
          "glue:CreateCatalog",
          "glue:UpdateCatalog",
          "glue:DeleteCatalog",
          "glue:GetCatalog",
          "glue:GetCatalogs",
          "glue:GetDatabase",
          "glue:GetDatabases",
          "glue:CreateDatabase",
          "glue:UpdateDatabase",
          "glue:DeleteDatabase",
          "glue:GetConnections",
          "glue:SearchTables",
          "glue:GetTable",
          "glue:CreateTable",
          "glue:UpdateTable",
          "glue:DeleteTable",
          "glue:GetTableVersions",
          "glue:GetPartitions",
          "glue:GetTables",
          "glue:ListWorkflows",
          "glue:BatchGetWorkflows",
          "glue:DeleteWorkflow",
          "glue:GetWorkflowRuns",
          "glue:StartWorkflowRun",
          "glue:GetWorkflow",
          "s3:ListBucket",
          "s3:GetBucketLocation",
          "s3:ListAllMyBuckets",
          "s3:GetBucketAcl",
          "iam:ListUsers",
          "iam:ListRoles",
          "iam:GetRole",
          "iam:GetRolePolicy"
        ]
        Resource = "*"
      },
      {
        Sid = "AWSLakeFormationDataAdminDeny"
        Effect = "Deny"
        Action = [
          "lakeformation:PutDataLakeSettings"
        ]
        Resource = "*"
      },
      {
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject"
        ]
        Resource = "arn:aws:s3:::ban-useast1-tu-bucket/*"
        Effect = "Allow"
      },
      {
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject"
        ]
        Resource = "arn:aws:s3::tu-bucket/*"
        Effect = "Allow"
      },
      {
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject"
        ]
        Resource = "arn:aws:s3:::tu-bucket/*"
        Effect = "Allow"
      },
      {
        Action = [
          "s3:GetObject",
          "s3:PutObject"
        ]
        Resource = [
          "arn:aws:s3:::tu-bucket/*",
          "arn:aws:s3:::tu-bucket/*"
        ]
        Effect = "Allow"
      },
      {
        Action = [
          "iam:PassRole"
        ]
        Resource = "*"
        Effect = "Allow"
      },
      # Permisos para los buckets definidos por las variables Terraform
      {
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject",
          "s3:ListBucket"
        ]
        Effect = "Allow"
        Resource = [
          "arn:aws:s3:::${var.s3_script_bucket}/*",
          "arn:aws:s3:::${var.s3_script_bucket}",
          "arn:aws:s3:::${var.s3_data_bucket}/*",
          "arn:aws:s3:::${var.s3_data_bucket}",
          "arn:aws:s3:::${var.s3_temp_dir}/*",
          "arn:aws:s3:::${var.s3_temp_dir}"
        ]
      }
    ]
  })
}

# Asociar la política al rol
resource "aws_iam_role_policy_attachment" "glue_job_policy_attachment" {
  role       = aws_iam_role.glue_job_role.name
  policy_arn = aws_iam_policy.glue_job_policy.arn
}

# Crear grupo de seguridad para los trabajos de Glue si se especifica una VPC
resource "aws_security_group" "glue_job_sg" {
  count       = var.vpc_id != "" ? 1 : 0
  name        = "${var.prefix}-glue-job-sg"
  description = "Security group for Glue Jobs"
  vpc_id      = var.vpc_id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all outbound traffic"
  }

  tags = merge(
    var.common_tags,
    {
      Name = "${var.prefix}-glue-job-sg"
    }
  )
}

# Crear los recursos de Glue Job para cada trabajo definido
resource "aws_glue_job" "jobs" {
  for_each = { for job in var.glue_jobs : job.name => job }

  name              = "${var.prefix}-${each.value.name}"
  role_arn          = aws_iam_role.glue_job_role.arn
  glue_version      = each.value.glue_version
  worker_type       = each.value.worker_type
  number_of_workers = each.value.number_of_workers
  timeout           = each.value.timeout
  max_retries       = each.value.max_retries

  command {
    name            = each.value.command_name
    script_location = "s3://${var.s3_script_bucket}/${each.value.script_location}"
    python_version  = each.value.python_version
  }

  default_arguments = merge(
    {
      "--job-language"                     = "python"
      "--enable-job-insights"              = "true"
      "--enable-continuous-cloudwatch-log" = "true"
      "--enable-metrics"                   = "true"
      "--job-bookmark-option"              = each.value.job_bookmark_option
      "--TempDir"                          = "s3://${var.s3_temp_dir}"
    },
    each.value.default_arguments
  )

  # Configuración de seguridad si está habilitada
  security_configuration = var.security_configuration != "" ? var.security_configuration : null

  # Configuración de VPC si se proporcionan los IDs de subred
  dynamic "execution_property" {
    for_each = each.value.max_concurrent_runs != null ? [1] : []
    content {
      max_concurrent_runs = each.value.max_concurrent_runs
    }
  }

  dynamic "connections" {
    for_each = length(each.value.connections) > 0 ? [1] : []
    content {
      connections = each.value.connections
    }
  }

  dynamic "notification_property" {
    for_each = each.value.notify_delay_after != null ? [1] : []
    content {
      notify_delay_after = each.value.notify_delay_after
    }
  }

  tags = merge(
    var.common_tags,
    each.value.tags,
    {
      Name = "${var.prefix}-${each.value.name}"
    }
  )
}

resource "aws_glue_trigger" "job_triggers" {
  for_each = { for trigger in var.job_triggers : trigger.name => trigger }

  name     = "${var.prefix}-${each.value.name}"
  type     = each.value.type
  schedule = each.value.type == "SCHEDULED" ? each.value.schedule : null
  enabled  = each.value.enabled

  dynamic "actions" {
    for_each = each.value.job_names
    content {
      job_name = "${var.prefix}-${actions.value}"
      timeout  = each.value.timeout
    }
  }

  dynamic "predicate" {
    # El predicate solo se crea si el tipo es "CONDITIONAL" y hay condiciones definidas
    for_each = each.value.type == "CONDITIONAL" && length(lookup(each.value, "conditions", [])) > 0 ? [1] : []
    content {

      dynamic "conditions" {
        for_each = each.value.conditions
        content {
          job_name     = "${var.prefix}-${conditions.value.job_name}"
          state        = conditions.value.state
          crawler_name = lookup(conditions.value, "crawler_name", null)
          crawl_state  = lookup(conditions.value, "crawl_state", null)
        }
      }
    }
  }

  tags = merge(
    var.common_tags,
    {
      Name = "${var.prefix}-${each.value.name}"
    }
  )
}

# Configuración de seguridad para Glue (si es necesario)
resource "aws_glue_security_configuration" "this" {
  count = var.create_security_configuration ? 1 : 0

  name = "${var.prefix}-security-config"

  encryption_configuration {
    cloudwatch_encryption {
      cloudwatch_encryption_mode = "SSE-KMS"
      kms_key_arn                = var.kms_key_arn
    }

    job_bookmarks_encryption {
      job_bookmarks_encryption_mode = "CSE-KMS"
      kms_key_arn                   = var.kms_key_arn
    }

    s3_encryption {
      s3_encryption_mode = "SSE-KMS"
      kms_key_arn        = var.kms_key_arn
    }
  }
}
