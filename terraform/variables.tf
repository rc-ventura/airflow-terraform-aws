variable "region" {
  type        = string
  description = "O nome da região onde iremos deployar a infraestrutura"
  default     = "us-east-1"
}

variable "ssh_pub_key" {
  type        = string
  description = "O PATH da chave SSH publica para configurar na instancia"
  default     = "~/.ssh/minha_chave_rsa.pub"
}