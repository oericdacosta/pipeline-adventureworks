# tap-mssql

Este repositório contém um pipeline dockerizado para extração de dados do SQL Server utilizando [Meltano](https://meltano.com/). Ele extrai os dados em formato Parquet e carrega os arquivos em um volume do Databricks, automatizando a transformação para o formato Delta.

O pipeline irá:

- Extrair dados das tabelas configuradas no `meltano.yml` usando o tap MSSQL.
- Carregar os dados como arquivos Parquet.
- Fazer upload dos arquivos Parquet para o Databricks.
- Executar um job no Databricks para converter Parquet em Delta.

## Estrutura do Projeto

- `meltano.yml`: Configuração dos extractors (taps) e loader (target-parquet).
- `entrypoint.sh`: Script principal de execução do pipeline.
- `Dockerfile`: Ambiente Docker para execução do pipeline.
- `.env_sample`: Exemplo de variáveis de ambiente necessárias.
- `.meltano/`: Diretório interno do Meltano.

## Pré-requisitos

- Docker
- Arquivo `.env` com as variáveis de ambiente necessárias:
    - `DATABRICKS_HOST`
    - `DATABRICKS_TOKEN`
    - `DATABRICKS_CATALOG`
    - `DATABRICKS_SCHEMA`
    - `DATABRICKS_VOLUME_RAW`
    - `DATABRICKS_FOLDER`
    - `DATABRICKS_JOB_ID`
    - `TAP_MSSQL_PASSWORD`
    - `TAP_MSSQL_HOST`
    - `TAP_MSSQL_PORT`
    - `TAP_MSSQL_USER`
    - `TAP_MSSQL_DATABASE`

    > Exemplo de `.env` disponível em `.env_sample`

## Configuração

1. Copie o arquivo `.env_sample` para `.env` e preencha com suas credenciais:

```sh
cp .env_sample .env
```

1. Preencha as variáveis do Databricks e do banco MSSQL no arquivo `.env`.

## Build da Imagem

```sh
docker build -t adw-meltano-bd .
```

## Execução do Pipeline

```sh
docker run --rm --env-file .env adw-meltano-bd
```

## Observações

- O arquivo `.env` **não deve ser versionado**.
- Para adicionar novas tabelas, edite o `meltano.yml` e o `entrypoint.sh`, e faça um novo build.
- Os dados extraídos são enviados automaticamente para o Databricks via CLI após o processamento.
- Após o envio de todos os arquivos para o Databricks, é realizada a execução automática dos jobs do Databricks para a transformação do Parquet em Delta.