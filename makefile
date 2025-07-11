# Makefile - Coloque este arquivo na raiz de `pipeline-adventureworks/`

# Adicionamos 'setup' à lista de comandos .PHONY
.PHONY: setup build build-api build-mssql start-airflow stop-airflow clean-airflow logs-airflow

# ==============================================================================
# === RECEITA PRINCIPAL (SETUP COMPLETO) =======================================
# ==============================================================================

# Esta receita executa o build e o start-airflow em sequência.
setup: build start-airflow
	@echo ""
	@echo "✅ Setup completo! Imagens construídas e ambiente Airflow iniciado."

# ==============================================================================
# === RECEITAS PARA CONSTRUIR AS IMAGENS DOS PIPELINES =========================
# ==============================================================================

build-api:
	@echo "--> Construindo imagem do pipeline da API: adw-meltano-bd:latest"
	@cd tap-api && docker build -t adw-meltano-bd:latest .

build-mssql:
	@echo "--> Construindo imagem do pipeline do MSSQL: ingestao-mssql:latest"
	@cd tap-mssql && docker build -t ingestao-mssql:latest .

build: build-api build-mssql

# ==============================================================================
# === RECEITAS PARA GERENCIAR O AMBIENTE AIRFLOW ===============================
# ==============================================================================

start-airflow:
	@echo "--> Iniciando ambiente Airflow com o script de setup..."
	@cd airflow && ./start.sh

stop-airflow:
	@echo "--> Parando ambiente Airflow..."
	@cd airflow && docker compose down

clean-airflow:
	@echo "--> ATENÇÃO: Limpando completamente o ambiente Airflow..."
	@cd airflow && docker compose down -v

logs-airflow:
	@echo "--> Exibindo logs do Airflow... (Pressione Ctrl+C para sair)"
	@cd airflow && docker compose logs -f