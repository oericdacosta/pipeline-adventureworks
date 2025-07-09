#!/bin/bash

if [ "$1" = "bash" ]; then
    exec /bin/bash
fi

echo "Setting up environment variables..."
export DATABRICKS_HOST=$DATABRICKS_HOST
export DATABRICKS_TOKEN=$DATABRICKS_TOKEN
export DATABRICKS_CATALOG=$DATABRICKS_CATALOG
export DATABRICKS_SCHEMA=$DATABRICKS_SCHEMA
export DATABRICKS_VOLUME_RAW=$DATABRICKS_VOLUME_RAW
export DATABRICKS_FOLDER=$DATABRICKS_FOLDER
export DATABRICKS_JOB_ID=$DATABRICKS_JOB_ID

export EXECUTION_DATE=$(date '+%Y-%m-%d')

echo "Extracting all tables from tap-mssql to target-parquet..."
meltano run tap-mssql target-parquet

echo "Data extraction completed. Uploading Parquet files to Databricks..."
TARGET_PATH="dbfs:/Volumes/$DATABRICKS_CATALOG/$DATABRICKS_SCHEMA/$DATABRICKS_VOLUME_RAW/$DATABRICKS_FOLDER/$EXECUTION_DATE/"

echo "Uploading files to unique, date-partitioned folder: $TARGET_PATH"
databricks fs cp ./output/ "$TARGET_PATH" --recursive

if [ $? -ne 0 ]; then
    echo "Error uploading Parquet files to Databricks"
    exit 1
fi
echo "Parquet files uploaded successfully."

echo "Running a single Databricks job to transform all Parquet files to Delta format..."
databricks jobs run-now --json '{
    "job_id": "'"$DATABRICKS_JOB_ID"'",
    "notebook_params": {
        "base_folder": "'"$DATABRICKS_FOLDER"'",
        "execution_date": "'"$EXECUTION_DATE"'",
        "catalog": "'"$DATABRICKS_CATALOG"'",
        "schema": "'"$DATABRICKS_SCHEMA"'"
    }
}'

if [ $? -ne 0 ]; then
    echo "Error running the Databricks job"
    exit 1
fi

echo "Databricks job completed successfully."