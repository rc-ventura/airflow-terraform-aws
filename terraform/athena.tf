
# Cria um workgroup chamado challenge, assim não precisamos configurar o S3 bucket pelo console
resource "aws_athena_workgroup" "challenge" {
  name          = "challenge"
  force_destroy = true

  configuration {
    enforce_workgroup_configuration    = false
    publish_cloudwatch_metrics_enabled = false

    result_configuration {
      output_location = "s3://${aws_s3_bucket.athena_query_results.bucket}/output/"
    }
  }
}

# Cria a base de dados chamado athena_<ID_UNICO>
resource "aws_athena_database" "challenge" {
  name   = "athena_${random_string.unique_id.id}"
  bucket = aws_s3_bucket.athena_query_results.id
}