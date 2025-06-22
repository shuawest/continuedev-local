# 🧠 DeepSeek Local AI Assistant for macOS (Apple Silicon)

This project sets up **DeepSeek-Coder 6.7B** as a **local code assistant** on your MacBook using:

- ✅ `llama.cpp` for fast local inference (with Metal support)
- ✅ `Continue.dev` for VSCode-based code chat + code assist
- ✅ Python virtual environment for safe package isolation
- ✅ Makefile-based automation for easy setup and use

---

## ✅ Prerequisites

Make sure you have the following installed:

- macOS with Apple Silicon (M1, M2, M3)
- [Homebrew](https://brew.sh/)
- Python 3.9+ (`python3`)
- [Visual Studio Code](https://code.visualstudio.com/)
- [Continue.dev Extension for VSCode](https://marketplace.visualstudio.com/items?itemName=Continue.continue)

---

## 🛠️ One-Time Setup

### 1. Clone and Enter the Project

```bash
git clone https://github.com/shuawest/continuedev-local
cd continuedev-local

2. Install Dependencies and Virtualenv

make setup

This will:
	•	Install cmake (via Homebrew)
	•	Create a Python virtualenv in .venv/
	•	Install the huggingface_hub Python package into it

3. Build llama.cpp with Apple Metal Acceleration

make build-llama

This clones and builds llama.cpp with GPU acceleration using CMake.

4. Download DeepSeek-Coder GGUF Model

make download-model

This downloads deepseek-coder-6.7b-instruct.Q4_K_M.gguf into ./models.

5. Configure Continue.dev to Use DeepSeek

make continue-config

This generates ~/.continue/config.yaml for Continue.dev to use your local DeepSeek model.

⸻

🚀 Usage

Start the LLM HTTP Server

make run-server

This launches llama.cpp as a REST server on localhost:8000.

Open a Terminal Chat with the Model

make run-cli

This uses cli-chat.sh to have a terminal conversation with DeepSeek.

Stop the Model Server

make stop-server

Check if the Server is Running

make status


⸻

🧩 Using with VSCode + Continue.dev
	1.	Install the Continue.dev extension
	2.	Run:

make continue-config

	3.	Open the Continue sidebar in VSCode
	4.	Chat, refactor, explain, or generate code using DeepSeek locally 🎉

⸻

🔄 Command Reference

Command	What it does
make setup	Installs cmake, sets up venv, installs Hugging Face tools
make build-llama	Builds llama.cpp from source
make download-model	Downloads DeepSeek GGUF model
make run-server	Starts inference server on port 8000
make run-cli	Starts a CLI chat session
make stop-server	Stops the inference server
make status	Shows if server is running
make continue-config	Configures Continue.dev to use DeepSeek locally
make clean	Deletes logs and build artifacts


⸻

📂 Project Structure

deepseek-local/
├── models/                  # GGUF models go here
├── llama.cpp/              # Built llama.cpp engine
├── logs/                   # Server logs
├── .venv/                  # Python virtual environment
├── Makefile                # Automates everything
├── cli-chat.sh             # Interactive CLI chat script
├── README.md               # This file


⸻

🧠 About DeepSeek-Coder

DeepSeek-Coder is a powerful, code-focused LLM trained on diverse programming languages and tasks. The 6.7B version offers a great balance of performance and accuracy for local dev.

⸻

🤝 License & Contributions

This setup is built from open source components and scripts. Contributions and improvements welcome!

---

✅ You can now paste this entire markdown into your `README.md` file — it’s complete and reflects your Makefile-driven DeepSeek local assistant setup. Let me know if you want a downloadable version or matching GitHub Actions automation.