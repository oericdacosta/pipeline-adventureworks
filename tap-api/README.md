# tap-api

Este repositório contém um pipeline dockerizado para extração de dados da API AdventureWorks utilizando [Meltano](https://meltano.com/). O pipeline extrai dados em formato JSONL e carrega os arquivos em um volume do Databricks, automatizando a conversão para o formato Delta.

## Funcionalidades

- Extração de dados de endpoints configurados em uma tap customizada ([`tap_adventureworks`](tap_adventureworks/tap.py)).
- Salvamento dos dados extraídos como arquivos JSONL.
- Upload automático dos arquivos JSONL para um volume do Databricks.
- Execução de job no Databricks para conversão dos arquivos JSONL em Delta.

## Estrutura do Projeto

- `meltano.yml`: Configuração do extractor custom (tap) e loader (target-jsonl).
- `entrypoint.sh`: Script principal para execução do pipeline.
- `Dockerfile`: Define o ambiente Docker para execução do pipeline.
- `.env_sample`: Exemplo de variáveis de ambiente necessárias.
- `tap_adventureworks/`: Código-fonte da tap customizada.

## Pré-requisitos

- Docker instalado.
- Conta e workspace no Databricks.
- Arquivo `.env` com as seguintes variáveis preenchidas:

    - `DATABRICKS_HOST`
    - `DATABRICKS_TOKEN`
    - `DATABRICKS_CATALOG`
    - `DATABRICKS_SCHEMA`
    - `DATABRICKS_VOLUME_RAW`
    - `DATABRICKS_FOLDER`
    - `DATABRICKS_JOB_ID`
    - `API_USERNAME`
    - `API_PASSWORD`

> Um exemplo de arquivo `.env` está disponível em `.env_sample`.

## Configuração

1. Copie o arquivo de exemplo e preencha com suas credenciais:

```sh
cp .env_sample .env
```

1. Edite o arquivo `.env` com as informações do Databricks e da API.

1. Configure os streams/endpoints a serem extraídos em [`tap_adventureworks/tap.py`](tap_adventureworks/tap.py) e em [`tap_adventureworks/streams.py`](tap_adventureworks/streams.py).

## Build da Imagem Docker

Execute o comando abaixo para construir a imagem Docker:

```sh
docker build -t adw-meltano-bd .
```

## Execução do Pipeline

Execute o pipeline com o comando:

```sh
docker run --rm --env-file .env adw-meltano-bd
```

## Observações

- O arquivo `.env` **não deve ser versionado**.
- Para adicionar novas tabelas, edite o `tap_adventureworks/tap.py`, `tap_adventureworks/streams.py` e, se necessário, ajuste o `entrypoint.sh`. Em seguida, faça um novo build da imagem.
- Os dados extraídos são enviados automaticamente para o Databricks após o processamento.
- Após o upload dos arquivos JSONL, o job do Databricks é executado automaticamente para a conversão em Delta.
