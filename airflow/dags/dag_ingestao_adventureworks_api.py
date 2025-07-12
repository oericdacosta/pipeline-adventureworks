from __future__ import annotations

import pendulum
from airflow.models.dag import DAG
from airflow.providers.docker.operators.docker import DockerOperator

default_args = {
    "owner": "seu_nome",
    "start_date": pendulum.datetime(2025, 7, 8, tz="America/Sao_Paulo"),
    "retries": 1,
}

with DAG(
    dag_id="ingestao_adventureworks_api",
    default_args=default_args,
    description="DAG para orquestrar a ingestão diária de dados da API AdventureWorks.",
    schedule_interval="@daily",
    catchup=False,
    tags=["adventureworks", "ingestao", "api", "databricks"],
) as dag:

    task_run_api_pipeline = DockerOperator(
        task_id="executa_pipeline_docker_api",
        image="adw-meltano-bd:latest",
        docker_url="unix://var/run/docker.sock",
        network_mode="bridge",
        auto_remove=True,
        environment={
            # Variáveis do Databricks
            "DATABRICKS_HOST":       "{{ var.value.DATABRICKS_HOST }}",
            "DATABRICKS_TOKEN":      "{{ var.value.DATABRICKS_TOKEN }}",
            "DATABRICKS_CATALOG":    "{{ var.value.DATABRICKS_CATALOG }}",
            "DATABRICKS_SCHEMA":     "{{ var.value.DATABRICKS_SCHEMA }}",
            "DATABRICKS_VOLUME_RAW": "{{ var.value.DATABRICKS_VOLUME_RAW }}",
            "DATABRICKS_FOLDER":     "{{ var.value.DATABRICKS_FOLDER }}",
            "DATABRICKS_JOB_ID":     "{{ var.value.DATABRICKS_JOB_ID }}",

            # --- MUDANÇA AQUI ---
            # Adicionamos as credenciais da API que estavam faltando
            "API_USERNAME":          "{{ var.value.API_USERNAME }}",
            "API_PASSWORD":          "{{ var.value.API_PASSWORD }}",

            # Data de execução
            "EXECUTION_DATE":        "{{ ds }}",
        },
    )
