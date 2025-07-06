#!/bin/bash

# Se um argumento 'bash' for passado, abre um terminal dentro do contêiner para debug
if [ "$1" = "bash" ]; then
    exec /bin/bash
fi

# Exporta as variáveis de ambiente para que fiquem disponíveis para os comandos
echo "Setting up environment variables..."
export DATABRICKS_HOST=$DATABRICKS_HOST
export DATABRICKS_TOKEN=$DATABRICKS_TOKEN
export DATABRICKS_CATALOG=$DATABRICKS_CATALOG
export DATABRICKS_SCHEMA=$DATABRICKS_SCHEMA
export DATABRICKS_VOLUME_RAW=$DATABRICKS_VOLUME_RAW
export DATABRICKS_FOLDER=$DATABRICKS_FOLDER
export DATABRICKS_JOB_ID=$DATABRICKS_JOB_ID
export DATETIME=$(date '+%Y%m%d_%H%M')

# --- SEÇÃO OTIMIZADA ---
# Executa a extração do Meltano para TODAS as tabelas de uma só vez
echo "Extracting all tables from tap-mssql to target-parquet..."
meltano run tap-mssql target-parquet

# Faz o upload de todos os arquivos Parquet para o Databricks de uma vez
echo "Data extraction completed. Uploading Parquet files to Databricks..."
databricks fs cp ./output/ "dbfs:/Volumes/$DATABRICKS_CATALOG/$DATABRICKS_SCHEMA/$DATABRICKS_VOLUME_RAW/$DATABRICKS_FOLDER/" --recursive

# Verifica se o upload falhou
if [ $? -ne 0 ]; then
    echo "Error uploading Parquet files to Databricks"
    exit 1
fi
echo "Parquet files uploaded successfully."

# Aciona um ÚNICO job no Databricks
echo "Running a single Databricks job to transform all Parquet files to Delta format..."
databricks jobs run-now --json '{
    "job_id": "'"$DATABRICKS_JOB_ID"'",
    "notebook_params": {
        "folder_volume": "'"$DATABRICKS_FOLDER"'",
        "catalog": "'"$DATABRICKS_CATALOG"'",
        "schema": "'"$DATABRICKS_SCHEMA"'"
    }
}'

# Verifica se a execução do job falhou
if [ $? -ne 0 ]; then
    echo "Error running the Databricks job"
    exit 1
fi

echo "Databricks job completed successfully."