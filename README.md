# el-pipeline-adw

Este repositório contém pipelines e componentes para extração, transformação e carga de dados (EL Pipeline) utilizando diferentes tecnologias e integrações com Databricks.

## Documentação dos Componentes

Cada componente do projeto possui sua própria documentação detalhada. Acesse os links abaixo para mais informações sobre cada parte do pipeline:

- [tap-mssql](./tap-mssql/README.md): Pipeline dockerizado para extração de dados de banco de dados MSSQL utilizando Meltano.
- [tap-api](./tap-api/README.md): Pipeline dockerizado para extração de dados de API utilizando Meltano.
- [src](./src/README.md): Notebooks para realizar a transformação do arquivo JSONL/Parquet para Delta Tables.

> Consulte cada README específico para detalhes de configuração, execução e requisitos de cada componente.

---
**Observação:** Este README serve como índice central do projeto. Para instruções detalhadas, acesse os READMEs das subpastas.