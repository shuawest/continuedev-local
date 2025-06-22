#!/bin/bash
MODEL_PATH="./models/deepseek-coder-6.7b-instruct.Q4_K_M.gguf"
LLAMA_BIN="./llama.cpp/main"

echo "💬 DeepSeek CLI Chat - type 'exit' to quit"
while true; do
    read -rp "You > " PROMPT
    [[ "$PROMPT" == "exit" ]] && break
    "$LLAMA_BIN" -m "$MODEL_PATH" -p "$PROMPT" --n-predict 300 --color
done
