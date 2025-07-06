#!/bin/bash

if [ "$1" = "bash" ]; then
    exec /bin/bash
fi

echo "Setting up environment variables..."
# source .env
export DATABRICKS_HOST=$DATABRICKS_HOST
export DATABRICKS_TOKEN=$DATABRICKS_TOKEN
export DATABRICKS_CATALOG=$DATABRICKS_CATALOG
export DATABRICKS_SCHEMA=$DATABRICKS_SCHEMA
export DATABRICKS_VOLUME_RAW=$DATABRICKS_VOLUME_RAW
export DATABRICKS_FOLDER=$DATABRICKS_FOLDER
export DATABRICKS_JOB_ID=$DATABRICKS_JOB_ID


echo "Extracting data from api to jsonl..."
meltano run tap-adventureworks target-jsonl


echo "Data extraction completed. Uploading JSONL files to Databricks..."
databricks fs cp ./output/ dbfs:/Volumes/$DATABRICKS_CATALOG/$DATABRICKS_SCHEMA/$DATABRICKS_VOLUME_RAW/$DATABRICKS_FOLDER/ --recursive

if [ $? -ne 0 ]; then
    echo "Error uploading JSONL files to Databricks"
    exit 1
fi
echo "JSONL files uploaded successfully."

echo "Running a single Databricks job to transform all JSONL files to Delta format..."
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