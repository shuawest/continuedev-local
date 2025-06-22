# Makefile for running DeepSeek with Continue.dev integration

# Configurable variables
export MODEL_REPO=TheBloke/Deepseek-Coder-6.7B-Instruct-GGUF
export MODEL_FILE=deepseek-coder-6.7b-instruct.Q4_K_M.gguf
export MODEL_DISPLAY=DeepSeek Local
export MODEL_PROVIDER=openai
export MODEL_NAME=deepseek-chat
export MODEL_API_BASE=http://localhost:8000/v1
export CHAT_TEMPERATURE=0.7
export CHAT_MAX_TOKENS=2048
export CODE_TEMPERATURE=0.2
export CODE_MAX_TOKENS=512
export VENV_DIR=.venv
export LLAMA_DIR=$(CURDIR)/llama.cpp
export CONFIG_TEMPLATE=config.yaml.tmpl
export CONFIG_OUTPUT=$(HOME)/.continue/config.yaml
export SERVER_BIN=$(LLAMA_DIR)/build/bin/llama-server
export SERVER_LOG=logs/server.log

# Default target
.DEFAULT_GOAL := help

help: ## Show help
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "🛠  \033[36m%-20s\033[0m %s\n", $$1, $$2}'

setup: ## Setup virtualenv, dependencies, and CLI tools
	@echo "🧪 Setting up environment..."
	@test -d $(VENV_DIR) || python3 -m venv $(VENV_DIR)
	@. $(VENV_DIR)/bin/activate && pip install --upgrade pip wheel > /dev/null
	@. $(VENV_DIR)/bin/activate && pip install huggingface_hub jinja2-cli > /dev/null
	@command -v cmake >/dev/null || (echo "⛔️ CMake not found. Please install with 'brew install cmake'" && exit 1)
	@command -v huggingface-cli >/dev/null || (echo "⛔️ huggingface-cli not found. Please install with 'brew install huggingface-cli'" && exit 1)
	@echo "✅ Setup complete."

build-llama: ## Clone and build llama.cpp
	@git clone https://github.com/ggerganov/llama.cpp.git || true
	@cd llama.cpp && mkdir -p build && cd build && cmake .. && make -j

download-model: ## Download DeepSeek-Coder GGUF model from Hugging Face
	@echo "⬇️  Downloading DeepSeek-Coder GGUF model..."
	@mkdir -p models
	@. $(VENV_DIR)/bin/activate && python3 -c "from huggingface_hub import hf_hub_download; hf_hub_download(repo_id='$(MODEL_REPO)', filename='$(MODEL_FILE)', local_dir='models')"

run-server: ## Run the local LLM server
	@echo "🚀 Starting LLM server..."
	@mkdir -p logs
	@nohup $(SERVER_BIN) -m models/$(MODEL_FILE) --port 8000 --ctx-size 4096 > $(SERVER_LOG) 2>&1 &
	@sleep 2
	@pgrep -f "$(SERVER_BIN)" > /dev/null && echo "🟢 Server running on http://localhost:8000" || (echo "❌ Server failed to start. Check $(SERVER_LOG)" && exit 1)

stop-server: ## Stop the local LLM server
	@echo "🛑 Stopping LLM server..."
	@pgrep -f "$(SERVER_BIN)" > /dev/null && pkill -f "$(SERVER_BIN)" && echo "✅ Server stopped." || echo "⚠️  No running server found."

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