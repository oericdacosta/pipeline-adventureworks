#!/bin/bash
set -e

echo "--- Iniciando ambiente Airflow de forma controlada ---"

# 1. Executa a tarefa de inicialização do banco de dados e a remove ao final
echo "Passo 1/4: Garantindo que o banco de dados está migrado..."
docker compose run --rm airflow-init

# 2. Sobe os serviços principais em segundo plano
echo "Passo 2/4: Subindo os serviços Airflow (webserver e scheduler)..."
docker compose up -d airflow-webserver airflow-scheduler

# 3. Aguarda um pouco para garantir que o webserver esteja pronto
echo "Passo 3/4: Aguardando 20 segundos para o webserver..."
sleep 20

# 4. Cria o usuário e importa variáveis de forma segura com o usuário 'airflow'
echo "Passo 4/4: Criando usuário e importando variáveis do .env..."
docker compose run --rm --user airflow airflow-webserver bash -c "
    echo 'Criando usuário admin...' &&
    airflow users create \
        --username \$AIRFLOW_ADMIN_USER \
        --firstname Admin \
        --lastname User \
        --role Admin \
        --email admin@example.com \
        -p \$AIRFLOW_ADMIN_PASSWORD || echo 'Usuário já existe, pulando criação.'

    echo 'Importando variáveis de configuração...' &&
    airflow variables set DATABRICKS_HOST \"\$DATABRICKS_HOST\" &&
    airflow variables set DATABRICKS_CATALOG \"\$DATABRICKS_CATALOG\" &&
    airflow variables set DATABRICKS_SCHEMA \"\$DATABRICKS_SCHEMA\" &&
    airflow variables set DATABRICKS_VOLUME_RAW \"\$DATABRICKS_VOLUME_RAW\" &&
    airflow variables set DATABRICKS_FOLDER \"\$DATABRICKS_FOLDER\" &&
    airflow variables set DATABRICKS_JOB_ID \"\$DATABRICKS_JOB_ID\" &&
    airflow variables set API_USERNAME \"\$API_USERNAME\" &&
    airflow variables set API_PASSWORD \"\$API_PASSWORD\" &&
    airflow variables set DATABRICKS_TOKEN \"\$DATABRICKS_TOKEN\"
"

echo ""
echo "-------------------------------------"
echo "✅ Ambiente Airflow está pronto!"
echo "Acesse em: http://localhost:8080"
echo "Login: ${AIRFLOW_ADMIN_USER}"
echo "-------------------------------------"
