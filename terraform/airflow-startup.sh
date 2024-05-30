#!/bin/bash

# Atualizando a lista de repositórios e pacotes disponiveis
sudo apt-get update

# Instalando python3-pip
sudo apt-get install python3-pip sqlite3 -yq

# Instalamos airflow com algumas bibliotecas adicionais para conseguir conversar com alguns serviços da AWS
sudo python3 -m pip install apache-airflow[s3,aws]
sudo python3 -m pip install pyOpenSSL --upgrade

# Criamos um usuário airflow para não rodar o serviço como root - Segurança em primeiro lugar
sudo useradd --shell /bin/bash --user-group --create-home airflow

# Criando os arquivos de serviço dos Airflow Webserver e Airflow Scheduler para não precisar iniciar manuamente se o servidor for reiniciado
sudo bash -c 'cat << EOF > /etc/systemd/system/airflow-webserver.service
[Unit]
Description=Airflow webserver daemon

[Service]
EnvironmentFile=/etc/environment
User=airflow
Group=airflow
Type=simple
ExecStart= /usr/local/bin/airflow webserver
Restart=on-failure
RestartSec=5s
PrivateTmp=true

[Install]
WantedBy=multi-user.target

EOF'

sudo bash -c 'cat << EOF > /etc/systemd/system/airflow-scheduler.service
[Unit]
Description=Airflow scheduler daemon

[Service]
EnvironmentFile=/etc/environment
User=airflow
Group=airflow
Type=simple
ExecStart=/usr/local/bin/airflow scheduler
Restart=always
RestartSec=5s

[Install]
WantedBy=multi-user.target

EOF'

# Configura o Airflow para ser iniciado pela primeira vez
sudo -u airflow bash -c "if [ ! -f /home/airflow/airflow/airflow.db ]; then airflow db init; fi"
sudo -u airflow sed -i 's/load_examples = True/load_examples = False/' /home/airflow/airflow/airflow.cfg

# Cria o diretório para armazenar as DAGs
sudo -u airflow mkdir -p /home/airflow/airflow/dags

# Configura o Airflow para operar como serviço
sudo systemctl enable airflow-webserver.service
sudo systemctl enable airflow-scheduler.service

# Aqui iniciamos os serviços
sudo systemctl start airflow-scheduler
sudo systemctl start airflow-webserver

# Cria os usuários necessários

# Cria o usuário com permissão de Admin
sudo -u airflow airflow users create \
    --username admin \
    --role Admin \
    --password RFN8p9aNbgea8AHQBc6Z \
    --firstname Airflow \
    --lastname Admin \
    --email admin@dominio.com

# Cria o usuário com permissão de Criar e Triggar DAGs
sudo -u airflow airflow users create \
    --username writer \
    --role Op \
    --password Aicie5ca5iebaihi5agh \
    --firstname Airflow \
    --lastname Writer \
    --email writer@dominio.com

# Cria o usuário com permissão apenas de visualização
sudo -u airflow airflow users create \
    --username reader \
    --role Viewer \
    --password Euboojooweiph1Ai6noo \
    --firstname Airflow \
    --lastname Reader \
    --email reader@dominio.com

# Cria o diretório de staging dos deploys
sudo -u ubuntu mkdir /home/ubuntu/dags

# Cria o script que copia os dags do usuario ubuntu para o airflow
sudo -u ubuntu bash -c 'cat << EOF > /home/ubuntu/copy-dags.sh
#!/bin/bash

sudo cp -R /home/ubuntu/dags/* /home/airflow/airflow/dags/
sudo chown -R airflow: /home/airflow/airflow/dags
EOF'

# Configura o script com permissão de execução
sudo -u ubuntu chmod a+x /home/ubuntu/copy-dags.sh