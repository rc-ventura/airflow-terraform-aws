# Utilizamos essa random string para nomear os S3, ja que os nomes precisa ser unicos.
resource "random_string" "unique_id" {
  length  = 4
  special = false
  lower   = true
  upper   = false
}