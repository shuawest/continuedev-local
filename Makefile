# Makefile for running LLMs with Continue.dev integration

# Load selected model config
ENV_LOCAL := .env.local
ifeq ("$(wildcard $(ENV_LOCAL))","")
  $(error ❌ No .env.local file found. Please run 'make select-model MODEL=name')
endif
include $(ENV_LOCAL)

MODEL_MK := model-configs/$(MODEL).mk
ifeq ("$(wildcard $(MODEL_MK))","")
  $(error ❌ Model config '$(MODEL)' not found in model-configs/. Available: $(shell ls model-configs | sed 's/\.mk//' | xargs))
endif
include $(MODEL_MK)

# Constants and paths
export VENV_DIR := .venv
export LLAMA_DIR := $(CURDIR)/llama.cpp
export CONFIG_TEMPLATE := config-templates/$(MODEL).tmpl
export CONFIG_OUTPUT := $(HOME)/.continue/config.yaml
export SERVER_BIN := $(LLAMA_DIR)/build/bin/llama-server
export SERVER_LOG := logs/server.log

# Default target
.DEFAULT_GOAL := help

help: ## Show help
	@echo "📌 Current model: $(MODEL)"
	@echo ""
	@echo "🛠️  Available commands:"
	@grep -hE '^[a-zA-Z0-9_-]+:.*?## ' $(firstword $(MAKEFILE_LIST)) \
	| sed -E 's/^([a-zA-Z0-9_-]+):.*## (.*)/    \1\t\2/' \
	| expand -t20
	@echo ""
	@echo "📦 Available models:"
	@ls model-configs | sed 's/\.mk//' | awk '{print "    • " $$1}'
build-llama: ## Clone and build llama.cpp
	@git clone https://github.com/ggerganov/llama.cpp.git || true
	@cd llama.cpp && mkdir -p build && cd build && cmake .. && make -j

download-model: ## Download GGUF model from Hugging Face
	@echo "⬇️  Downloading $(MODEL_DISPLAY) model..."
	@mkdir -p models
	@. $(VENV_DIR)/bin/activate && python3 -c \
		"from huggingface_hub import hf_hub_download; \
		 hf_hub_download(repo_id='$(MODEL_REPO)', filename='$(MODEL_FILE)', local_dir='models')"

# Add this target to your full Makefile

.PHONY: download-all-models
download-all-models: ## Download all GGUF models
	@echo "⬇️  Downloading all configured GGUF models..."
	@for mk in $(wildcard model-configs/*.mk); do \
	  echo "📥 Downloading model from $$mk..."; \
	  MODEL_FILE=""; \
	  MODEL_REPO=""; \
	  . $$mk; \
	  if [ -n "$$MODEL_FILE" ] && [ -n "$$MODEL_REPO" ]; then \
	    . $(VENV_DIR)/bin/activate && \
	    python3 -c "from huggingface_hub import hf_hub_download; hf_hub_download(repo_id='$$MODEL_REPO', filename='$$MODEL_FILE', local_dir='models')"; \
	  else \
	    echo "⚠️  Skipping $$mk — MODEL_FILE or MODEL_REPO missing."; \
	  fi \
	done
	@echo "✅ All models processed."
	
run-server: ## Run the local LLM server
	@echo "🚀 Starting LLM server..."
	@mkdir -p logs
	@nohup $(SERVER_BIN) -m models/$(MODEL_FILE) --port 8000 --ctx-size 4096 > $(SERVER_LOG) 2>&1 &
	@sleep 2
	@pgrep -f "$(SERVER_BIN)" > /dev/null && echo "🟢 Server running on http://localhost:8000" || \
		(echo "❌ Server failed to start. Check $(SERVER_LOG)" && exit 1)

stop-server: ## Stop the local LLM server
	@echo "🛑 Stopping LLM server..."
	@pgrep -f "$(SERVER_BIN)" > /dev/null && pkill -f "$(SERVER_BIN)" && echo "✅ Server stopped." || \
		echo "⚠️  No running server found."

status: ## Check if the server is running
	@pgrep -f "$(SERVER_BIN)" >/dev/null && echo "🟢 Model server is running." || echo "🔴 No model server running."

log: ## Tail the model server logs
	@echo "📄 Tailing $(SERVER_LOG)..."
	@tail -f $(SERVER_LOG)

continue-config: ## Generate Continue.dev config.yaml from template
	@echo "⚙️  Generating Continue.dev config.yaml..."
	@mkdir -p $$(dirname $(CONFIG_OUTPUT))
	@MODEL_DISPLAY="$(MODEL_DISPLAY)" \
	  MODEL_PROVIDER="$(MODEL_PROVIDER)" \
	  MODEL_NAME="$(MODEL_NAME)" \
	  MODEL_API_BASE="$(MODEL_API_BASE)" \
	  CHAT_TEMPERATURE="$(CHAT_TEMPERATURE)" \
	  CHAT_MAX_TOKENS="$(CHAT_MAX_TOKENS)" \
	  CODE_TEMPERATURE="$(CODE_TEMPERATURE)" \
	  CODE_MAX_TOKENS="$(CODE_MAX_TOKENS)" \
	  envsubst < $(CONFIG_TEMPLATE) > $(CONFIG_OUTPUT)
	@echo "✅ Config written to $(CONFIG_OUTPUT)"

login: ## Log in to Hugging Face
	@echo "🔑 Logging into Hugging Face..."
	@huggingface-cli login

select-model: ## Select a model and persist it in .env.local (e.g., make select-model MODEL=deepseek)
ifndef MODEL
	$(error ❌ MODEL not specified. Usage: make select-model MODEL=deepseek)
endif
	@echo "✅ Selected model: $(MODEL)"
	@echo "MODEL=$(MODEL)" > .env.local