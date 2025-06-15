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

# Executa a extração do Meltano para cada tabela, gerando os arquivos Parquet
echo "Extracting data from taps to target-parquet..."

echo "Product"
meltano run tap-mssql-product target-parquet

echo "ProductCategory"
meltano run tap-mssql-productcategory target-parquet

echo "ProductSubCategory"
meltano run tap-mssql-productsubcategory target-parquet

echo "SalesOrderDetail"
meltano run tap-mssql-salesorderdetail target-parquet

echo "SalesOrderHeader"
meltano run tap-mssql-salesorderheader target-parquet

echo "Customer"
meltano run tap-mssql-customer target-parquet

echo "salescountryregioncurrency"
meltano run tap-mssql-salescountryregioncurrency target-parquet

echo "salescreditcard"
meltano run tap-mssql-salescreditcard target-parquet

echo "salescurrency"
meltano run tap-mssql-salescurrency target-parquet

echo "salescurrencyrate"
meltano run tap-mssql-salescurrencyrate target-parquet

echo "salespersoncreditcard"
meltano run tap-mssql-salespersoncreditcard target-parquet

echo "salessalesorderheadersalesreason"
meltano run tap-mssql-salessalesorderheadersalesreason target-parquet

echo "salessalesperson"
meltano run tap-mssql-salessalesperson target-parquet

echo "salessalespersonquotahistory"
meltano run tap-mssql-salessalespersonquotahistory target-parquet

echo "salessalesreason"
meltano run tap-mssql-salessalesreason target-parquet

echo "salessalestaxrate"
meltano run tap-mssql-salessalestaxrate target-parquet

echo "salessalesterritory"
meltano run tap-mssql-salessalesterritory target-parquet

echo "salessalesterritoryhistory"
meltano run tap-mssql-salessalesterritoryhistory target-parquet

echo "salesshoppingcartitem"
meltano run tap-mssql-salesshoppingcartitem target-parquet

echo "salesspecialoffer"
meltano run tap-mssql-salesspecialoffer target-parquet

echo "salesspecialofferproduct"
meltano run tap-mssql-salesspecialofferproduct target-parquet

echo "salesstore"
meltano run tap-mssql-salesstore target-parquet


# Faz o upload de todos os arquivos Parquet para o Databricks de uma vez
echo "Data extraction completed. Uploading Parquet files to Databricks..."
databricks fs cp ./output/ dbfs:/Volumes/$DATABRICKS_CATALOG/$DATABRICKS_SCHEMA/$DATABRICKS_VOLUME_RAW/$DATABRICKS_FOLDER/ --recursive

# Verifica se o upload falhou
if [ $? -ne 0 ]; then
    echo "Error uploading Parquet files to Databricks"
    exit 1
fi
echo "Parquet files uploaded successfully."

# --- SEÇÃO OTIMIZADA ---
# Aciona um ÚNICO job no Databricks, passando apenas os parâmetros de localização.
# O notebook agora é responsável por encontrar e processar todos os arquivos.
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