# Aqui criamos o Bucket que irá armazenar os CSVs gerado pelo job do Airflow
resource "aws_s3_bucket" "airflow_job_results" {
  bucket        = "airflow-output-${random_string.unique_id.id}"
  force_destroy = true
}

# Aqui criamos o Bucket que irá armazenar os outputs das queries do athena.
resource "aws_s3_bucket" "athena_query_results" {
  bucket        = "athena-output-${random_string.unique_id.id}"
  force_destroy = true
}