# Dual-model Makefile for Continue.dev with config templates and full model awareness

ENV_LOCAL := .env.local
ifeq ("$(wildcard $(ENV_LOCAL))","")
  $(error ❌ No .env.local file found. Please create one with CHAT_MODEL and CODE_MODEL.)
endif
include $(ENV_LOCAL)

CHAT_MK := $(firstword $(wildcard model-configs/$(CHAT_MODEL)-chat.mk) $(wildcard model-configs/$(CHAT_MODEL)-dual.mk))
CODE_MK := $(firstword $(wildcard model-configs/$(CODE_MODEL)-code.mk) $(wildcard model-configs/$(CODE_MODEL)-dual.mk))

ifeq ("$(CHAT_MK)","")
  $(error ❌ Could not find chat model config for '$(CHAT_MODEL)'. Expected one of: $(CHAT_MODEL)-chat.mk or $(CHAT_MODEL)-dual.mk)
endif
ifeq ("$(CODE_MK)","")
  $(error ❌ Could not find code model config for '$(CODE_MODEL)'. Expected one of: $(CODE_MODEL)-code.mk or $(CODE_MODEL)-dual.mk)
endif

include $(CHAT_MK)
CHAT_MODEL_FILE := $(MODEL_FILE)
CHAT_MODEL_REPO := $(MODEL_REPO)
CHAT_MODEL_PORT := 8001
CHAT_MODEL_NAME := $(MODEL_NAME)
CHAT_MODEL_API_BASE := http://${BIND_ADDR}:${CHAT_MODEL_PORT}/v1
CHAT_MODEL_DISPLAY := $(MODEL_DISPLAY)
CHAT_CTX_SIZE := $(if $(MODEL_CTX_SIZE),$(MODEL_CTX_SIZE),4096)
CHAT_TEMPERATURE := $(CHAT_TEMPERATURE)
CHAT_MAX_TOKENS := $(CHAT_MAX_TOKENS)

include $(CODE_MK)
CODE_MODEL_FILE := $(MODEL_FILE)
CODE_MODEL_REPO := $(MODEL_REPO)
CODE_MODEL_PORT := 8002
CODE_MODEL_NAME := $(MODEL_NAME)
CODE_MODEL_API_BASE := http://${BIND_ADDR}:${CODE_MODEL_PORT}/v1
CODE_MODEL_DISPLAY := $(MODEL_DISPLAY)
CODE_CTX_SIZE := $(if $(MODEL_CTX_SIZE),$(MODEL_CTX_SIZE),4096)
CODE_TEMPERATURE := $(CODE_TEMPERATURE)
CODE_MAX_TOKENS := $(CODE_MAX_TOKENS)

VENV_DIR := .venv
CONFIG_TEMPLATE := config.yaml.tmpl
CONFIG_OUTPUT := $(HOME)/.continue/config.yaml
SERVER_BIN := $(CURDIR)/llama.cpp/build/bin/llama-server
CODE_SERVER_BIN := python3 -m llama_cpp.server
LOG_DIR := logs

.DEFAULT_GOAL := help

help:
	@echo "🧠 Chat model: $(CHAT_MODEL) ($(CHAT_MODEL_DISPLAY), ctx-size=$(CHAT_CTX_SIZE))"
	@echo "💡 Code model: $(CODE_MODEL) ($(CODE_MODEL_DISPLAY), ctx-size=$(CODE_CTX_SIZE))"
	@echo ""
	@echo "📦 Available models:"
	@echo "   🧠 Chat:"
	@ls model-configs/*-chat.mk 2>/dev/null | sed 's|model-configs/||;s|-chat\.mk$$||' | awk '{print "     • " $$1}'
	@echo "   👨‍💻 Code:"
	@ls model-configs/*-code.mk 2>/dev/null | sed 's|model-configs/||;s|-code\.mk$$||' | awk '{print "     • " $$1}'
	@echo "   🔁 Dual:"
	@ls model-configs/*-dual.mk 2>/dev/null | sed 's|model-configs/||;s|-dual\.mk$$||' | awk '{print "     • " $$1}'
	@echo ""
	@echo "🛠️  Commands:"
	@grep -hE '^[a-zA-Z0-9_-]+:.*## ' $(firstword $(MAKEFILE_LIST)) | \
	sed -E 's/^([a-zA-Z0-9_-]+):.*## (.*)/    \1\t\2/' | expand -t20

setup: ## One-time environment setup including Python server
	@echo "🐍 Creating virtual environment and installing dependencies..."
	@test -d $(VENV_DIR) || python3 -m venv $(VENV_DIR)
	@. $(VENV_DIR)/bin/activate && pip install --upgrade pip && pip install llama-cpp-python[server] huggingface_hub

build-llama: ## Clone and build llama.cpp
	@git clone https://github.com/ggerganov/llama.cpp.git || true
	@cd llama.cpp && mkdir -p build && cd build && cmake .. && make -j

download-models: ## Download chat and code models
	@echo "⬇️ Downloading chat model: $(CHAT_MODEL_DISPLAY)..."
	@. $(VENV_DIR)/bin/activate && \
	  python3 -c "from huggingface_hub import hf_hub_download; \
	  hf_hub_download(repo_id='$(CHAT_MODEL_REPO)', filename='$(CHAT_MODEL_FILE)', local_dir='models')"
	@echo "⬇️ Downloading code model: $(CODE_MODEL_DISPLAY)..."
	@. $(VENV_DIR)/bin/activate && \
	  python3 -c "from huggingface_hub import hf_hub_download; \
	  hf_hub_download(repo_id='$(CODE_MODEL_REPO)', filename='$(CODE_MODEL_FILE)', local_dir='models')"

download-all-models: ## Download all GGUF models from model-configs/
	@echo "⬇️ Downloading all configured GGUF models..."
	@for mk in $(wildcard model-configs/*.mk); do \
	  echo "📥 Processing $$mk..."; \
	  unset MODEL_FILE MODEL_REPO; \
	  . $$mk; \
	  if [ -n "$$MODEL_FILE" ] && [ -n "$$MODEL_REPO" ]; then \
	    echo "⬇️  Downloading $$MODEL_FILE from $$MODEL_REPO..."; \
	    . $(VENV_DIR)/bin/activate && \
	    python3 -c "from huggingface_hub import hf_hub_download; \
	                hf_hub_download(repo_id='$$MODEL_REPO', filename='$$MODEL_FILE', local_dir='models')"; \
	  else \
	    echo "⚠️  Skipping $$mk — MODEL_FILE or MODEL_REPO missing."; \
	  fi \
	done
	@echo "✅ All models processed."

start: ## Launch both chat and code models
	@echo "🚀 Launching chat model on port $(CHAT_MODEL_PORT)..."
	@mkdir -p $(LOG_DIR)
	@echo "nohup $(SERVER_BIN) -m models/$(CHAT_MODEL_FILE) --port $(CHAT_MODEL_PORT) --ctx-size $(CHAT_CTX_SIZE) > $(LOG_DIR)/chat.log 2>&1 &"
	@nohup $(SERVER_BIN) -m models/$(CHAT_MODEL_FILE) --port $(CHAT_MODEL_PORT) --ctx-size $(CHAT_CTX_SIZE) > $(LOG_DIR)/chat.log 2>&1 &
	@sleep 2
	@echo "🚀 Launching code model on port $(CODE_MODEL_PORT)..."
	@echo "nohup $(CODE_SERVER_BIN) --model models/$(CODE_MODEL_FILE) --port $(CODE_MODEL_PORT) --n_ctx $(CODE_CTX_SIZE) > $(LOG_DIR)/code.log 2>&1 &"
	@nohup $(CODE_SERVER_BIN) --model models/$(CODE_MODEL_FILE) --port $(CODE_MODEL_PORT) --n_ctx $(CODE_CTX_SIZE) > $(LOG_DIR)/code.log 2>&1 &
	@sleep 2
	@echo "✅ Both models launched."

stop: ## Stop all running model servers
	@pkill -f "models/$(CHAT_MODEL_FILE)" || true
	@kill -9 $(lsof -ti :8001) || true
	@pkill -f "models/$(CODE_MODEL_FILE)" || true
	@kill -9 $(lsof -ti :8002) || true
	@echo "🛑 Servers stopped."

status: ## Check model server status
	@pgrep -f "models/$(CHAT_MODEL_FILE)" > /dev/null && echo "🟢 Chat model running on port $(CHAT_MODEL_PORT)" || echo "🔴 Chat model not running"
	@lsof -i :8001 || true
	@pgrep -f "models/$(CODE_MODEL_FILE)" > /dev/null && echo "🟢 Code model running on port $(CODE_MODEL_PORT)" || echo "🔴 Code model not running"
	@lsof -i :8002 || true

log: ## Tail logs
	@tail -f $(LOG_DIR)/chat.log $(LOG_DIR)/code.log

continue-config: ## Generate Continue.dev config.yaml from template
	@echo "⚙️ Generating Continue.dev config from template..."
	@mkdir -p $$(dirname $(CONFIG_OUTPUT))
	@export CHAT_MODEL_NAME="$(CHAT_MODEL_NAME)"; \
	 export CHAT_MODEL_DISPLAY="$(CHAT_MODEL_DISPLAY)"; \
	 export CHAT_MODEL_API_BASE="$(CHAT_MODEL_API_BASE)"; \
	 export CHAT_TEMPERATURE="$(CHAT_TEMPERATURE)"; \
	 export CHAT_MAX_TOKENS="$(CHAT_MAX_TOKENS)"; \
	 export CODE_MODEL_NAME="$(CODE_MODEL_NAME)"; \
	 export CODE_MODEL_DISPLAY="$(CODE_MODEL_DISPLAY)"; \
	 export CODE_MODEL_API_BASE="$(CODE_MODEL_API_BASE)"; \
	 export CODE_TEMPERATURE="$(CODE_TEMPERATURE)"; \
	 export CODE_MAX_TOKENS="$(CODE_MAX_TOKENS)"; \
	 envsubst < $(CONFIG_TEMPLATE) > $(CONFIG_OUTPUT)
	@echo "✅ Config written to $(CONFIG_OUTPUT)"

login: ## Hugging Face login
	@huggingface-cli login