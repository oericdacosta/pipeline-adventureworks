#!/bin/bash
set -e

echo "--- Iniciando ambiente Airflow de forma controlada ---"

# Passos 1, 2 e 3 permanecem os mesmos...
echo "Passo 1/4: Garantindo que o banco de dados está migrado..."
docker compose run --rm airflow-init

echo "Passo 2/4: Subindo os serviços Airflow (webserver e scheduler)..."
docker compose up -d airflow-webserver airflow-scheduler

echo "Passo 3/4: Aguardando 20 segundos para o webserver..."
sleep 20

# Passo 4: Atualizamos este bloco para incluir as novas variáveis
echo "Passo 4/4: Criando usuário e importando TODAS as variáveis do .env..."
docker compose run --rm --user airflow airflow-webserver bash -c "
    echo 'Criando usuário admin...' &&
    airflow users create \
        --username \$AIRFLOW_ADMIN_USER \
        --firstname Admin \
        --lastname User \
        --role Admin \
        --email admin@example.com \
        -p \$AIRFLOW_ADMIN_PASSWORD || echo 'Usuário já existe, pulando criação.' &&
    
    echo 'Importando variáveis de configuração...' &&
    # Variáveis comuns do Databricks
    airflow variables set DATABRICKS_HOST \"\${DATABRICKS_HOST}\" &&
    airflow variables set DATABRICKS_CATALOG \"\${DATABRICKS_CATALOG}\" &&
    airflow variables set DATABRICKS_SCHEMA \"\${DATABRICKS_SCHEMA}\" &&
    airflow variables set DATABRICKS_VOLUME_RAW \"\${DATABRICKS_VOLUME_RAW}\" &&
    
    # Variáveis da API
    airflow variables set DATABRICKS_FOLDER \"\${DATABRICKS_FOLDER}\" &&
    airflow variables set DATABRICKS_JOB_ID \"\${DATABRICKS_JOB_ID}\" &&
    airflow variables set API_USERNAME \"\${API_USERNAME}\" &&
    airflow variables set API_PASSWORD \"\${API_PASSWORD}\" &&
    airflow variables set DATABRICKS_TOKEN \"\${DATABRICKS_TOKEN}\" &&

    # --- MUDANÇA AQUI: Adicionamos as variáveis do MSSQL ---
    airflow variables set TAP_MSSQL_HOST \"\${TAP_MSSQL_HOST}\" &&
    airflow variables set TAP_MSSQL_PORT \"\${TAP_MSSQL_PORT}\" &&
    airflow variables set TAP_MSSQL_USER \"\${TAP_MSSQL_USER}\" &&
    airflow variables set TAP_MSSQL_PASSWORD \"\${TAP_MSSQL_PASSWORD}\" &&
    airflow variables set TAP_MSSQL_DATABASE \"\${TAP_MSSQL_DATABASE}\" &&
    airflow variables set DATABRICKS_FOLDER_MSSQL \"\${DATABRICKS_FOLDER_MSSQL}\" &&
    airflow variables set DATABRICKS_JOB_ID_MSSQL \"\${DATABRICKS_JOB_ID_MSSQL}\"
"

echo ""
echo "-------------------------------------"
echo "✅ Ambiente Airflow está pronto!"
echo "Acesse em: http://localhost:8080"
echo "Login: \${AIRFLOW_ADMIN_USER}"
echo "-------------------------------------"