# Aqui pegamos a VPC default da região.
data "aws_vpc" "default" {}

# Aqui criamos o security group que irá liberar accesso à internet e acesso as portas para gerenciar a solução
resource "aws_security_group" "airflow" {
  name        = "airflow"
  description = "Security group to allow traffic to airflow instance"
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Permite a instancia conversar com a internet"
  }
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Libera porta para acessar instancia do Airflow via SSH"
  }
  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Libera porta para acessar a UI do Airflow"
  }

  vpc_id = data.aws_vpc.default.id

}

# Aqui buscamos a AMI mais recente do Ubuntu 22.04
data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # ID da conta da Canonical
}

# Aqui configura o IAM profile que será associado à instancia
resource "aws_iam_instance_profile" "airflow_profile" {
  name = "airflow-profile"
  role = aws_iam_role.airflow_role.name
}

# Aqui configura a chave SSH necessária para fazer o deploy das DAGs
resource "aws_key_pair" "deployer" {
  key_name   = "deployer-key"
  public_key = file(var.ssh_pub_key)
}

# Aqui criamos a instancia com o startup script que irá configurar o Airflow
resource "aws_instance" "airflow" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = "t3.small"
  vpc_security_group_ids = [aws_security_group.airflow.id]
  key_name               = aws_key_pair.deployer.id
  iam_instance_profile   = aws_iam_instance_profile.airflow_profile.name

  tags = {
    Name = "Airflow-Server"
  }

  user_data_replace_on_change = true
  user_data                   = file("airflow-startup.sh")

  metadata_options {
    http_tokens = "required"
  }
}