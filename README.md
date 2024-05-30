# Aiflow / Athena

Esse projeto contém os códigos necessário para configurar o ambiente de Aiflow e Athena.

## Estrutura de arquivos

```
README.md
dags/ # onde os dags são armazenados
├─ dag_athena_to_s3.py # DAG que executa queries no athena e exporta para o S3
terraform/ pasta principal das configurações do Terraform
├─ airflow-startup.sh # Arquivo com os script que configura a instancia do Airflow
├─ athena.tf # Configura os recursos necessários do Athena
├─ ec2.tf # Configura a instancia de Airflow e suas dependencias
├─ provider.tf # Configura os providers do Terraform (AWS)
├─ random.tf # Configura o ID randomico
├─ s3.tf # Configura os buckets S3
├─ variables.tf # Configura as variaves pricipais necessárias para executar o Terraform
├─ versions.tf # Mantém os registros das versões necessária para executar o Terraform
scripts/ # onde os dags são armazenados
├─ deploy-dag.sh # Copia os DAGs locais para o Servidor do Airflow
```

## Configurando a Infraestrutura

Inicia o Terraform e baixa as bibliotecas necessárias

```bash
terraform init
```

> Antes de planejar e aplicar as mudanças com o Terraform precisamos editar o arquivo `variables.tf` e colocar as configurações necessárias. Na variavel `ssh_pub_key` precisamos descomentar o atributo `default` e colocar o PATH da chave Publica do SSH para conseguir acessar a instancia. A chave pública geralmente é encontrada no arquivo `~/.ssh/id_rsa.pub` na maquina local do desenvolvedor.

Mostra o que será implementado com o Terraform

```bash
terraform plan
```

Aplica as mudanças na infraestrutura com o Terraform

```bash
terraform apply
```

## Deploy das DAGs

Primeiramente precisamos preencher as variáveis necessárias dentro do arquivo de DAG antes de fazer o deploy.

```python
ATHENA_DATABASE = "" # aqui colocamos o valor do comando "terraform output athena_database"
ATHENA_WORKGROUP = "" # aqui colocamos o valor do comando "terraform output athena_workgroup"
ATHENA_OUTPUT_S3_BUCKET = "" # aqui colocamos o valor do comando "terraform output athena_output_s3_bucket"
AIRFLOW_OUTPUT_S3_BUCKET = "" # aqui colocamos o valor do comando "terraform output airflow_output_s3_bucket"
```

Após modificar o DAG, realizamos o deploy executando o seguinte comando:

```bash
scripts/deploy-dag.sh
```