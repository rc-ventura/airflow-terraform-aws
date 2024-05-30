# Aqui criamos a role que irá ser associada ao profile da instancia que irá executar os jobs iniciados pelo Airflow.
resource "aws_iam_role" "airflow_role" {
  name = "airflow-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })

  inline_policy {
    name = "allow_airflow_athena_actions"

    policy = jsonencode({
      Version = "2012-10-17"
      Statement = [
        {
          Action = [
            "athena:StartQueryExecution",
            "athena:GetQueryResults",
            "athena:GetQueryExecution",
            "athena:GetWorkGroup",
            "athena:StopQueryExecution",
            "athena:GetTable",
            "athena:GetDatabase",
            "athena:BatchGetTable"
          ]
          Effect   = "Allow"
          Resource = "*"
        },
      ]
    })
  }

  inline_policy {
    name = "allow_airflow_glue_actions"

    policy = jsonencode({
      Version = "2012-10-17"
      Statement = [
        {
          Action = [
            "glue:GetDatabase",
            "glue:GetTable",
            "glue:CreateTable",
            "glue:DeleteTable"
          ]
          Effect   = "Allow"
          Resource = "*"
        },
      ]
    })
  }

  inline_policy {
    name = "allow_airflow_s3_actions"

    policy = jsonencode({
      Version = "2012-10-17"
      Statement = [
        {
          Action = [
            "s3:GetBucketLocation",
            "s3:GetObject",
            "s3:ListBucket",
            "s3:ListBucketMultipartUploads",
            "s3:ListMultipartUploadParts",
            "s3:AbortMultipartUpload",
            "s3:CreateBucket",
            "s3:PutObject"
          ]
          Effect   = "Allow"
          Resource = "*"
        },
      ]
    })
  }
}
