# Nesse arquivo controlamos a versão do terraform e das bibliotecas que iremos utilizara para provisionar a infraestrutura
terraform {
  required_version = "= 1.8.2"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "= 5.47.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "= 3.6.1"
    }
    null = {
      source  = "hashicorp/null"
      version = "= 3.2.2"
    }
  }
}
