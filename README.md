# 🧠 Continue.dev Local AI Assistant — Multi-Model Setup for macOS

This project sets up a **dual-model local AI assistant** with Continue.dev in VSCode, using:

- ✅ Local inference via `llama.cpp` or `llama-cpp-python`
- ✅ Code + chat model pairing (separate ports, separate configs)
- ✅ Easy model swapping with `Makefile` and `.env.local` config
- ✅ Template-driven config for `~/.continue/config.yaml`
- ✅ Full compatibility with GGUF models on Hugging Face

---

## 🚀 Quickstart

### 1. Prerequisites

Make sure you have:

- macOS (Apple Silicon preferred)
- [Homebrew](https://brew.sh/)
- Python 3.9+
- [Visual Studio Code](https://code.visualstudio.com/)
- [Continue.dev Extension](https://marketplace.visualstudio.com/items?itemName=Continue.continue)

### 2. Clone and Configure

```bash
git clone https://github.com/YOURNAME/continuedev-local
cd continuedev-local
cp .env.local.example .env.local  # Set CHAT_MODEL and CODE_MODEL
```

### 3. One-Time Setup

```bash
make setup        # Installs Python deps
make build-llama  # Builds llama.cpp
make download-models  # Downloads selected models
```

### 4. Run Models

```bash
make run-dual         # Starts both chat and code models
make continue-config  # Writes ~/.continue/config.yaml
```

In VSCode, reload Continue.dev and start coding/chatting.

---

## 📦 Available Models

All models are in GGUF format and downloaded from Hugging Face.

| Name                          | Type        | Params | Context | License     | Strengths                                     |
|-------------------------------|-------------|--------|---------|-------------|-----------------------------------------------|
| **DeepSeek-Coder-6.7B**       | Code        | 6.7B   | 16K     | MIT         | Strong project-level Python/code completion   |
| **CodeLlama-7B-Instruct**     | Code        | 7B     | 16K     | Llama2 CC   | Good code + long context; Meta-backed         |
| **WizardCoder-7B-Python**     | Code        | 7B     | 4K      | Llama2 CC   | Top-tier Python completion, Alpaca-style      |
| **Phind-CodeLlama-34B-v2**    | Code        | 34B    | 4K+     | Llama2 Code | State-of-the-art open model for coding        |
| **Replit-Code-v1.5-3B**       | Code        | 3B     | 2K      | MIT         | Fast autocomplete for many languages          |
| **StarCoder2-3B**             | Code        | 3B     | 16K     | OpenRAIL-M  | FIM support, great for in-IDE insertion       |
| **Mistral-7B-Instruct-v0.2**  | Chat        | 7B     | 32K     | Apache 2.0  | Strong general-purpose assistant              |
| **OpenHermes-2.5-Mistral**    | Chat        | 7B     | 8K      | Apache 2.0  | Balanced chat + code; very articulate         |
| **TinyLlama-1.1B-Chat**       | Chat        | 1.1B   | 4K      | Apache 2.0  | Very lightweight; chat-only                   |
| **Zephyr-7B-Alpha**           | Chat        | 7B     | 8K      | MIT         | Helpful, aligned, uncensored chat model       |
| **Qwen3-8B**                  | Chat        | 8B     | 32K     | Apache 2.0  | Reasoning-rich, multilingual, agentic         |

To use a model, set `CHAT_MODEL` and `CODE_MODEL` in `.env.local` to match the model name prefix (e.g. `deepseek-coder`, `zephyr`).

---

## 🛠️ Makefile Commands

| Command               | Description                                 |
|------------------------|---------------------------------------------|
| `make setup`           | Setup Python venv and install dependencies |
| `make build-llama`     | Build `llama.cpp` from source              |
| `make download-models` | Download selected models in `.env.local`   |
| `make download-all-models` | Download all known GGUF models         |
| `make run-dual`        | Launch both chat and code servers          |
| `make stop-dual`       | Kill all model processes                   |
| `make status`          | Show running server status                 |
| `make log`             | Tail logs for both servers                 |
| `make continue-config` | Generate `~/.continue/config.yaml`         |

---

## 📁 Folder Layout

```
continuedev-local/
├── models/              # All downloaded GGUF models go here
├── model-configs/       # Per-model metadata in .mk files
├── llama.cpp/           # llama.cpp repo (built by Makefile)
├── .env.local           # Your selected model pairing
├── config.yaml.tmpl     # Template for Continue.dev
├── Makefile             # Full automation logic
└── logs/                # Logs for chat/code model servers
```

---

## 💡 Tips

- You can mix models from different families (e.g., DeepSeek + Zephyr).
- Log files are written to `logs/chat.log` and `logs/code.log`.
- Use `make continue-config` anytime you change models.
- For best performance, use 4-bit GGUF models and install Metal support in `llama.cpp`.

---

## 🔐 Hugging Face Auth

To download gated models (like Meta's Llama-based ones), run:

```bash
make login
```

---

Enjoy your local AI coding assistant experience!