# Aqui retornamos o IP da instancia do Airflow
output "instance_ip_address" {
  value = aws_instance.airflow.public_ip
}

# Aqui retornamos o endereço HTTP para acessar o Airflow
output "airflow_endpoint" {
  value = "http://${aws_instance.airflow.public_ip}:8080"
}

# Aqui retornamos o nome do database criado no Athena
output "athena_database" {
  value = aws_athena_database.challenge.name
}

# Aqui retornamos o nome do workgroup criado no Athena
output "athena_workgroup" {
  value = aws_athena_workgroup.challenge.name
}

# Aqui retornamos o nome do bucket criado para armazenar as saidas das queria no Athena
output "athena_output_s3_bucket" {
  value = aws_s3_bucket.athena_query_results.bucket
}

# Aqui retornamos o nome do bucket criado para armazenar os CSVs gerados pela DAG
output "airflow_output_s3_bucket" {
  value = aws_s3_bucket.airflow_job_results.bucket
}

# Aqui retornamos a chave ssh para ser utilizada no script de deployar as DAGg
output "ssh_key_path" {
  value = replace(var.ssh_pub_key, ".pub", "")
}

