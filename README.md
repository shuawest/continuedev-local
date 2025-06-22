Multi-Model Local LLM Setup

This README provides instructions for setting up and using multiple local LLM models, along with a catalog of the available models and their details. We include guidance on installation, model usage, the model catalog (with summaries, pros, and cons of each model), and a command reference for common operations.

Setup
	1.	Install Dependencies: Ensure you have a compatible LLM runner. We recommend using llama.cpp or a UI like text-generation-webui, which support the GGUF quantized models listed here. You will need a recent version of llama.cpp (August 27, 2023 or later) to use GGUF v2 models ￼ ￼. If using Python, install the latest transformers library (>=4.34) and optionally ctransformers or llama-cpp-python for GGUF support ￼ ￼.
	2.	Hardware Requirements: These models range from 1.1B to 34B parameters. Smaller models (1B–7B) can run on CPU or modest GPUs, while the 34B model may require >15 GB VRAM (or use 8-bit/4-bit quantization on CPU with ~8–10 GB RAM). See model notes for RAM/VRAM needs. For example, CodeLlama-7B-Instruct in 4-bit uses ~6.5 GB RAM.
	3.	Download Models: Use the huggingface-hub CLI or web UI to download the model files. It’s not necessary to clone entire repos; you can download just the desired quantized file. For example, to get a 4-bit quantized CodeLlama-7B-Instruct model:

pip install huggingface-hub>=0.17.1
huggingface-cli download TheBloke/CodeLlama-7B-Instruct-GGUF codellama-7b-instruct.Q4_K_M.gguf --local-dir ./models

Repeat for each model (see Available Models below for repository names and recommended files). You can also use wildcard patterns or a model downloader script ￼. If you have a fast connection, setting HF_HUB_ENABLE_HF_TRANSFER=1 can speed up downloads ￼.

	4.	Model Installation: Place the downloaded .gguf files in your models directory (or configure your UI to the download location). In text-generation-webui, for example, put each model in a subfolder under models/ and rename the GGUF file to model.gguf if required by the UI. In llama.cpp, you can keep the filenames as is and point to them with the -m argument.
	5.	Configuration: No special configuration is required for basic use. The GGUF files contain all necessary tokenizer and rope scaling metadata. For extended context models, llama.cpp will automatically apply the correct RoPE settings from the file ￼. Ensure your runtime uses the appropriate context length (-c parameter in llama.cpp) for models that support >2048 tokens. For example, use -c 4096 for 4K context models or -c 16384 for 16K context models as needed.

Usage

Once installed, you can run prompts on any of the models using either a CLI or a UI:
	•	Using llama.cpp CLI: Run the main binary with model file and generation parameters. For example:

./main -m models/codellama-7b-instruct.Q4_K_M.gguf -c 4096 -n 256 --temp 0.7 --repeat_penalty 1.1 \
       -p "[INST] Write a Python function to sort a list. [/INST]"

This loads the CodeLlama-7B-Instruct model in 4-bit mode, sets context to 4096 tokens, and prompts it (in CodeLlama’s instruction format) to generate a sorted list function. Adjust -c (context) and -n (max tokens) per your needs. Omit -ngl or GPU offload options if running on pure CPU, or use -ngl <layers> to offload that many layers to GPU for acceleration ￼.

	•	Using text-generation-webui or Other UIs: Launch the UI and select the model from the model list. The UI will handle prompt formatting for chat/instruct models automatically if it recognizes the model. For example, selecting Zephyr-7B-Alpha in the UI will apply its chat template with system/user/assistant roles as needed. Ensure you choose the correct prompt template if the UI doesn’t detect it (e.g. Alpaca format for WizardCoder, or CodeLlama format with [INST] for CodeLlama models).
	•	Prompt Formats: Each model may expect prompts in a slightly different format:
	•	CodeLlama-7B-Instruct uses Meta’s special format with [INST] ... [/INST] tags around the user prompt ￼. The example above shows this format.
	•	DeepSeek-Coder-6.7B and Mistral-7B-Instruct follow a similar instruct style (DeepSeek’s template includes a system instruction restricting to CS topics ￼, and Mistral uses the Llama2-style [INST] tokens).
	•	OpenHermes-2.5-Mistral uses a ChatML-like format (it was trained with ShareGPT style conversations ￼), but simple user prompts should work – the model was optimized for general chat/instruct.
	•	Phind-CodeLlama-34B-v2 was trained on an instruction-following dataset; it accepts Alpaca/Vicuna style prompts (User/Assistant roles) ￼. In a UI, use the Vicuna template or plain Q&A.
	•	Qwen-3 8B uses its own two-mode prompting. By default, enable the model’s thinking mode for complex tasks. In Transformers, you would call tokenizer.apply_chat_template(messages, enable_thinking=True) ￼. In a UI without explicit support, a simple prompt works, but to utilize Qwen fully, refer to their documentation for using the <s><|im_start|>system tokens and the special <think> parser. (For basic use, you can treat Qwen like a normal chat model.)
	•	Replit-Code 3B is a code completion model. It works best if you prompt it with code context or a function signature and let it complete. It may not respond well to plain English instructions since it’s not instruction-tuned ￼. For example, provide a partial code snippet and let it continue.
	•	StarCoder2-3B is also a code model (not instruct). Use it by giving some code prompt or docstring and it will complete the code. It was trained with a fill-in-the-middle ability ￼, so you can use <fim> tokens if supported, though standard usage is to prompt with code.
	•	TinyLlama-1.1B-Chat and Zephyr-7B-Alpha are both fine-tuned for chat. They follow a similar format: a system prompt and conversational turns. The example above for Zephyr (pirate chatbot system prompt) shows how the HF chat template is applied ￼ ￼. In most UIs, choosing an appropriate chat preset (e.g. Alpaca or Vicuna style) will format it correctly. TinyLlama was aligned with UltraChat and UltraFeedback (like Zephyr) ￼, so it behaves similarly to Zephyr in expected format (it uses the same <|system|>, <|user|>, <|assistant|> tokens as in the example ￼).
	•	WizardCoder-Python-7B uses the Alpaca instruction format (single-turn instruction -> response) ￼. Provide a programming task or question as the “instruction” and it will output the answer or code.

In summary, you can interact with each model by providing a prompt or conversation. The model will generate a completion or answer. Use the Available Models section below to understand each model’s strengths and ideal use cases, and adjust your prompting strategy accordingly (e.g. prefer code context for code-focused models, or plain language for chat models).

Available Models

Below is a catalog of the installed models, including a brief summary and key pros/cons of each:

CodeLlama-7B-Instruct (Meta)

Summary: Part of Meta’s Code Llama family, this is a 7B-parameter model fine-tuned for coding instructions ￼. It is designed to generate code and explain solutions, using the Llama 2 architecture. Notably, CodeLlama supports long context lengths (trained on 16K tokens and reportedly stable up to 100K tokens) ￼ ￼, allowing it to handle large code files or multi-file reasoning. It comes under the Llama 2 community license. Intended use is code generation and completion in natural language or code-oriented queries.

Pros:
	•	Good coding ability for its size, often outperforming older 7B models on code tasks. It was specifically tuned to follow instructions in coding scenarios (e.g. “Write a function that X”) and produce runnable code ￼.
	•	Extended context window (16k) enables it to consider much larger code bases or instructions than many 7B models ￼.
	•	As part of a well-known family, it benefits from Meta’s robust training; it can handle code in multiple programming languages and integrate comments/explanations in responses.

Cons:
	•	Being 7B, its performance on very complex problems is limited compared to larger models. It may struggle with logic-intensive tasks that aren’t strictly coding.
	•	As an instruct model focused on code, it may be less conversational for general Q&A. It expects the special [INST]...[/INST] prompt format, which can be less intuitive (UIs usually handle this).
	•	While it has a long context, using extremely long inputs (50k+ tokens) may be slow or occasionally lead to instability in generation. Quality may degrade with very large contexts despite support.

DeepSeek-Coder-6.7B-Instruct (DeepSeek AI)

Summary: DeepSeek Coder 6.7B is a 6.7B-parameter model from DeepSeek AI, trained from scratch on an enormous 2 trillion token dataset (87% code, 13% natural text in English/Chinese) ￼. It was later fine-tuned on 2B tokens of instruction data for coding assistance ￼. It uses a Llama-like architecture with a 16K context window for project-level code understanding ￼. Intended use is code generation, especially in a programming assistant role (it even has a system prompt to refuse non-CS questions ￼).

Pros:
	•	Trained on a massive corpus, giving it state-of-the-art coding performance among open models of its size at the time of release ￼. It supports multiple programming languages and can handle completion and infilling (fill-in-the-middle).
	•	16K context window means it can take in large code files or multiple classes/functions and still produce relevant output, supporting “project-level” code tasks ￼.
	•	Strong performance in benchmarks: it was near state-of-the-art for 7B-class code models and even competitive with larger models on HumanEval and other tests ￼. DeepSeek reported it as surpassing older models for coding tasks.

Cons:
	•	The model is heavily oriented to coding; it may refuse or do poorly on general queries by design (the instruction template biases it towards computer science topics only ￼).
	•	Its conversational ability is limited outside of programming context. It might follow the instruction to only answer CS-related questions and politely refuse others.
	•	6.7B parameters still falls short of larger models in complex coding scenarios (e.g. it may not perform as well as 13B+ models on very complex algorithm design or reasoning about code).
	•	Some users have reported difficulty in loading certain quantizations without the proper inference libraries (ensure your environment supports GPTQ/GGUF as needed).

Mistral-7B-Instruct-v0.2 (Mistral AI)

Summary: Mistral 7B Instruct v0.2 is an instruction-tuned variant of the base Mistral-7B model. Mistral-7B, developed by Mistral AI, is known for its strong performance outperforming Llama 2 13B on many benchmarks despite only 7B parameters ￼. The v0.2 update of the base introduced a 32K context window (up from 8K in v0.1) and other architectural tweaks ￼, and this Instruct model is fine-tuned on that base to follow user instructions. It’s a general-purpose assistant model (Apache 2.0 license) suited for a wide range of tasks, from Q&A and explanation to creative writing, while also handling coding queries.

Pros:
	•	High performance for 7B: Mistral’s base model is very well-trained; it “outperforms Llama 2 13B on all benchmarks [Mistral] tested” according to the authors ￼. The instruct version inherits this strong foundation, making it exceptionally good for a 7B model.
	•	Long context (32K): This model supports up to 32,768 tokens context ￼, which is huge for a 7B model. You can feed large documents or lengthy conversations without hitting context limits (ensure to set -c 32768 if using llama.cpp).
	•	Versatile and conversational: Fine-tuned to follow instructions, it can engage in multi-turn dialogue with the special [INST] ... [/INST] format and yields helpful responses. It’s capable in coding tasks and general knowledge queries, making it a strong all-rounder at low compute cost.

Cons:
	•	As an alpha/early instruct release (v0.2 of Mistral, which was still in active development), it may have some quirks or lesser polish in instruction-following compared to more mature models like Llama 2 Chat. Mistral v0.3 has since come out addressing some issues.
	•	Potential instability at extreme context lengths: While 32K is supported, very long contexts could increase inference time and there’s some chance of quality degradation or unexpected behavior beyond 8K, since v0.2 was relatively new ￼.
	•	The model might lack explicit fine-tuning on human preference/safety datasets. It was primarily a demonstration of base model’s ability with a quick instruct fine-tune, so it might not be as tightly aligned (could produce refusals less often, but also might not have a strong filter on harmful content).
	•	It requires updated inference software due to its custom Mistral architecture (e.g. you need transformers >=4.33 with Mistral support or llama.cpp updated for Mistral). Older tools might not recognize the mistral model type without updates ￼ ￼.

OpenHermes-2.5-Mistral-7B (Teknium)

Summary: OpenHermes 2.5 is a fine-tuned model by Teknium built on the Mistral 7B base (likely v0.1). It is the successor to OpenHermes 2, incorporating additional coding data into the training mix ￼. It was trained on a large dataset of ~1 million high-quality examples, primarily generated by GPT-4 and others, including ~7–14% code instructions ￼. The result is a chat-oriented model that excels not only in conversation and creative tasks but also shows improved coding abilities (it boosted HumanEval pass@1 from ~43% to 50.7% with the added code training) ￼. OpenHermes 2.5 is open licensed (Apache-2.0) and aims to be a very well-rounded 7B assistant.

Pros:
	•	Balanced skills: Thanks to a diverse training set (coding + general QA), OpenHermes-2.5 performs well across many domains. It outperforms previous Hermes models (e.g. Nous-Hermes and OpenHermes 2) and most other Mistral fine-tunes in benchmarks ￼.
	•	Strong coding for a 7B: The inclusion of code instructions raised its coding benchmark scores significantly (HumanEval pass@1 ~50.7%) ￼, putting it near older 13B models in code and making it one of the better 7B coders.
	•	High-quality responses: Teknium leveraged GPT-4 generated data for training ￼, meaning the model learned from very fluent, well-structured answers. It often produces more verbose and articulate responses than a typical 7B. It’s noted for being conversationally engaging (the original Hermes was known for roleplay and creativity, and this inherits that with improvements).
	•	Good compliance: OpenHermes was designed as a chat assistant; it attempts to follow user instructions accurately and maintain context over multiple turns (the training format included ShareGPT-style dialogues ￼).

Cons:
	•	No official long context: If based on Mistral v0.1, it has an 8K context. (If Teknium fine-tuned on v0.1, context is 8192 tokens.) This is still longer than many models but not as high as Mistral v0.2 or Zephyr. It’s not explicitly stated that v0.2 base was used, so assume 8K context limit.
	•	Potential over-confidence: Models trained heavily on AI-generated data (especially GPT-4 outputs) may produce answers that sound very authoritative. OpenHermes can sometimes be prone to confidently incorrect statements (hallucinations) if the prompt goes into areas outside its training distribution.
	•	Slight regressions on certain benchmarks: The author noted a drop in BigBench score when adding code data ￼. This suggests that some niche or creativity benchmarks might be a bit lower than the previous version. So, there’s a small trade-off where focusing on code made it slightly worse on some broad knowledge tests, though overall gains outweighed this.
	•	As with any 7B, it still cannot match larger models in complex reasoning or very domain-specific knowledge. It’s strong for its size, but users with heavy tasks might hit its limits.

Phind-CodeLlama-34B-v2 (Phind)

Summary: Phind-CodeLlama-34B-v2 is a 34B-parameter code-specialized model fine-tuned by Phind. It builds on Meta’s Code Llama 34B and Phind’s earlier v1 model. Phind trained v2 on an additional 1.5B high-quality coding tokens ￼ (on top of a large code corpus used in v1). The result achieved 73.8% pass@1 on HumanEval ￼ – a record among open models, even exceeding GPT-4’s score on that benchmark ￼ ￼. Phind-CodeLlama-34B-v2 is proficient in multiple programming languages (Python, C/C++, Java, TypeScript, etc.) ￼ and is also instruction-tuned for ease of use. It uses the Llama 2 code model license (commercial use allowed under terms) and is intended for serious coding assistance and complex problem-solving.

Pros:
	•	State-of-the-art coding performance: This model is currently one of the best open models for code generation. Its HumanEval score ~73.8% ￼ rivals or surpasses private models – indicating it can often solve coding challenges as well as GPT-3.5+ tier systems. It handles complex algorithmic problems and can generate correct, efficient code.
	•	Instruction-tuned & multi-lingual: Unlike a pure code completion model, it has been instruction-finetuned (in Alpaca/Vicuna style) to be interactive and follow natural language prompts ￼. It can explain code, debug, and handle queries in at least a dozen programming languages. Phind specifically mentions strong proficiency in Python, C/C++, Java, TypeScript and more ￼.
	•	Large context (up to 4K or more): As a Llama 2 derivative, it natively supports 4K context. Some community versions may have extended that – but even 4K is usually enough for most single-file coding tasks. This allows it to take a substantial code base or problem description.
	•	Robust training methodology: Phind applied OpenAI’s decontamination process to ensure the eval benchmarks weren’t leaked into training ￼ ￼, lending credibility to its benchmark performance. Training was done with DeepSpeed and FlashAttention for quality, and no LoRA adapters – a full fine-tune for maximum performance ￼.

Cons:
	•	Resource-intensive: 34B parameters means this model is heavy. Running it requires significant VRAM (roughly 28–30 GB in 16-bit, or ~18 GB in 8-bit). The quantized GGUF 4-bit model is ~13–14 GB in size. Inference is slower compared to smaller models. It’s not suitable for real-time use on modest hardware.
	•	Narrow focus: This model’s prowess is in code. For general conversational tasks, simpler queries, or non-coding topics, it may be under-utilized or even somewhat less tuned. It will still follow instructions well, but a lot of its capacity is geared towards programming knowledge. Using it for everyday Q&A might not yield better results than a smaller model that’s more general.
	•	Potential verbosity: Being instruction-tuned, it might sometimes “explain” more than needed. For example, it might comment code or add extra clarifications. While often useful, it can be verbose. Users should be specific if they want only code output (e.g. prompt: “provide code only, no explanation”).
	•	Long generation latency: Due to model size, generating long outputs (say, hundreds of lines of code) can be slow. This might affect usability for very large code generation tasks unless running on powerful accelerators.

Qwen3-8B (Alibaba, Qwen v3)

Summary: Qwen3-8B is an 8.2B-parameter model from Alibaba’s Qwen series (v3). It is a dense (non-MoE) model designed for both strong reasoning and efficient dialogue ￼. Qwen3 introduces a unique feature: it can switch between “thinking” mode and “non-thinking” mode within a single model ￼. In thinking mode, it performs step-by-step logical reasoning, math, or code generation; in normal mode, it responds more directly and concisely. This gives Qwen3 a dynamic range in handling tasks optimally. It has significantly improved reasoning capabilities, surpassing Qwen2.5 and previous Qwen models on math, coding, and logic benchmarks ￼. It’s also highly multilingual (100+ languages supported) and tool-aware (designed to integrate with external tools/ APIs). Context length is very large: 32K tokens by default, extendable up to ~131K with specialized retrieval techniques ￼. License is Apache 2.0, making it business-friendly.

Pros:
	•	Advanced reasoning & coding: Qwen3-8B’s thinking mode allows it to tackle complex problems by internally working through steps. This yields better accuracy in math problems, logical reasoning, and generating correct code, outperforming earlier 7–8B models in those areas ￼.
	•	Flexible response style: The ability to turn off thinking mode means for simple queries it responds quickly and succinctly, whereas for complicated ones it can produce a chain-of-thought (which can even be extracted from the output) ￼ ￼. This makes it both efficient and deep as needed.
	•	Massive context window: 32,768 token context means it can handle very large inputs (documents, long dialogues, or multi-file code contexts). Moreover, with Alibaba’s YaRN extension, it can go up to 131K tokens ￼, which is virtually 100+ pages of text – useful for long documents or extensive retrieval augmented generation.
	•	Multilingual and aligned: It supports over 100 languages, making it useful in non-English contexts ￼. It’s also well-aligned with human preferences, having strengths in creative writing, role-playing, and detailed multi-turn conversations ￼. The model is reported to have superior alignment for engaging dialogues compared to its predecessors.
	•	Tool use and agentic abilities: Qwen3 is designed with agent tasks in mind. It can integrate with tools and APIs, and is among the top open models in complex agent-based task evaluations ￼. This means if you connect it to a plugin system or provide a structured way to query tools (like a calculator, web search), it’s adept at utilizing them.

Cons:
	•	Complex usage for full capability: Fully leveraging Qwen3’s thinking mode may require special prompting or code. In standard chat, by default it uses thinking mode (enable_thinking=True) which will include verbose reasoning in answers unless you parse it out ￼ ￼. Some users might find the <thought> content (if exposed) unwanted. Toggling modes via prompt tokens or API is an extra step that simpler models don’t need.
	•	Size vs. speed: 8B parameters is bigger than the common 7B, so it’s slightly more resource heavy. It’s still relatively lightweight, but with the 32K context, memory usage can spike if you actually use the full window. Also, very large contexts will slow down generation.
	•	Less field-tested: Qwen3 is a newer release and not as widely adopted yet. Minor integration issues can occur (e.g., you need very up-to-date Transformers library to avoid tokenizer errors, as “qwen3” might not be recognized by older versions ￼).
	•	Safety considerations: While Qwen3 has good alignment, its expanded capabilities (especially tool use or very long context) mean it hasn’t been as extensively safety-tested in real-world settings ￼ ￼. Caution is advised if used in production, as with any powerful model, to monitor outputs.

Replit-Code v1.5-3B (Replit)

Summary: Replit Code v1.5 (3B) is a 3.3B-parameter code generation model released by Replit. It’s trained on 1 trillion tokens of code drawn from permissively licensed sources (GitHub “The Stack” dataset and StackExchange Q&A) ￼. This model focuses on code completion – continuing code from a prompt – rather than general instruction following. It covers the top 30 programming languages and uses a custom 32k BPE vocabulary optimized for code ￼. Advanced training techniques (Grouped Query Attention, FlashAttention, ALiBi positional embedding, Lion optimizer, etc.) were used to maximize quality and efficiency ￼. According to Replit, it achieves leading results among 3B-size code models, even rivalling some 7B models on benchmarks ￼ ￼. License is permissive (MIT), and it’s intended as a foundation for coding tasks and further fine-tuning.

Pros:
	•	Lightweight with strong performance: Despite only 3B parameters, Replit v1.5 delivers state-of-the-art results for its size, topping HumanEval and MultiPL-E charts in the 3B category ￼. In Replit’s internal tests, a fine-tuned version even outperformed CodeLlama-7B on certain code benchmarks ￼.
	•	Trained on massive data: 1 trillion tokens is an enormous scale for a 3B model ￼. This extensive training (on diverse code and Q&A) gives it a surprisingly broad knowledge of libraries, algorithms, and programming patterns relative to its size.
	•	Optimized for code tasks: It has a 32K token vocabulary including a lot of programming keywords and symbols, which helps it generate code more fluently and with less fragmentation (e.g., it can output longer identifier names as single tokens). It also supports 30 programming languages, so it’s not limited to Python.
	•	Fast and resource-friendly: 3B parameters means this model can run on CPUs or very low-end GPUs. It’s well-suited for applications where real-time code suggestions are needed (e.g., IDE autocompletion) thanks to low latency and the use of efficient attention mechanisms (GQA) ￼.
	•	Open for commercial use: MIT licensed, and Replit encourages using it as a base for fine-tuning ￼. There are no strict usage limitations, making it easy to integrate into developer tools.

Cons:
	•	Not instruction-tuned: This model is not a conversational coder by default. It expects code context as input. If you prompt it with, “Write a function for X,” it might not respond as helpfully as an instruct-tuned model. Instead, it shines when you give it the start of a function or a code comment and let it complete. Using it in chat mode (without fine-tuning) can lead to it producing code or none at all because it wasn’t explicitly trained to obey natural language commands ￼.
	•	Limited context (relative to some): Context length is 2048 tokens (since no mention of extended context in training). This is plenty for code completion (it can handle quite a few lines of code above), but it cannot take very large code files at once unlike some larger models with 8K+ windows.
	•	Domain-specific: It’s specialized for code. Outside of programming, its performance is weak. It doesn’t “know” general world facts or chat naturally. If asked a question unrelated to coding, it might produce irrelevant text or just break down.
	•	Outputs may require formatting: As a completion model, it might not automatically include boilerplate unless prompted (e.g., it might not add the function signature unless you include the def line for it to continue). It also may produce only code, lacking explanatory text — which is great for some uses, but if you need an explanation, you’d have to prompt accordingly or fine-tune an instruct version.

StarCoder2-3B (BigCode)

Summary: StarCoder2-3B is a 3B-parameter model from Hugging Face’s BigCode project, representing the next generation of open code LLMs. Despite its small size, StarCoder2-3B was trained on 3+ trillion tokens of code and text, across 17 programming languages from The Stack v2 dataset ￼. It uses Grouped Query Attention and features a context window of 16,384 tokens (with an effective sliding window attention up to 4K) ￼. Additionally, it was trained with a fill-in-the-middle (FIM) objective ￼, meaning it can intelligently insert code into existing code bodies given prefix and suffix context. Notably, StarCoder2-3B outperforms the original StarCoder (15B) on many benchmarks, and generally outclasses other code models of similar size ￼. It’s released under the OpenRAIL-M license (permissive with some usage restrictions for misuse) and is aimed at code completion and generation tasks.

Pros:
	•	Extremely high training volume: 3 trillion tokens for a 3B model is an unprecedented scale ￼. This intensive training leads to exceptional performance for its size – BigCode reported that 3B outperforms their older 15B model on most coding benchmarks ￼. It has learned a wide array of coding patterns, algorithms, and even some natural language from documentation.
	•	Fill-in-the-middle capability: Thanks to FIM training, StarCoder2 can generate code not just by continuation but also by insertion. This is useful in IDE scenarios (e.g., generating code inside a partially written function). It can take a prompt like: # TODO implement function logic (in the middle of code) and fill in the code in between.
	•	Long context (16K): It can handle very long code files or multiple files concatenated. It applies sliding window attention for contexts beyond 4K tokens ￼, which optimizes performance while maintaining some awareness of earlier parts. This means you can feed in lots of code (e.g. an entire file of a few thousand lines) and still get sensible completions at the end or insertions in the middle.
	•	Strong multilingual code support: Covers 17 languages, including popular ones like Python, JavaScript, C++, Java, Go, etc., and even some niche ones, all learned from The Stack v2 ￼. It can switch between languages or complete code with mixed languages (like HTML with embedded JS) reasonably well.
	•	Small and efficient: 3B parameters with optimized attention means lower memory and faster inference. It’s feasible to run on CPU for lightweight use (memory footprint ~6.3 GB in BF16, and as low as ~3.4 GB with 4-bit quantization ￼ ￼). For fine-tuning or deployment, it’s much easier than dealing with 15B+ models.

Cons:
	•	Not instruction or chat tuned: Out-of-the-box, StarCoder2-3B is a pure code model. It won’t understand “plain English” instructions well. For example, asking “Please write a Python script to do X” may yield no answer or just repeat your prompt. It expects either code context or perhaps a docstring/comment prompt. (You can fine-tune or use an instruct wrapper, but vanilla usage is completion-oriented ￼.)
	•	Limited reasoning due to size: While it punches above its weight, it’s still 3B. For complex tasks requiring understanding of problem descriptions (especially if not given in code form), it may falter. It’s best used when the prompt provides enough scaffold (function signatures, comments, or test cases) for it to latch onto.
	•	OpenRAIL license: This license allows commercial use but has restrictions against certain uses (e.g., illegal or harmful uses). Users need to agree to abide by the ethical terms of use. It’s not as flexible as Apache/MIT in a legal sense – though for most applications this isn’t a problem, just something to note.
	•	FIM usage complexity: To use fill-in-the-middle, one must include special tokens or format the input in a specific way (the model card provides guidance and the Transformers library can handle it with proper tokenizers). If using basic interfaces, you might not leverage FIM. So, some advanced features require more technical integration.

TinyLlama-1.1B-Chat-v1.0 (TinyLlama Project)

Summary: TinyLlama-1.1B-Chat is a 1.1 billion parameter chat model, notable for being trained on a massive 3 trillion tokens from scratch ￼. The TinyLlama project’s goal was to see how a very small model performs when given an extremely large training budget. It uses the same architecture and tokenizer as Llama 2, making it a drop-in smaller variant ￼. After pretraining, this model was fine-tuned to be a conversational assistant: first on a variant of the UltraChat synthetic dialogue dataset, then aligned with Direct Preference Optimization (DPO) using the UltraFeedback dataset (GPT-4 ranked responses) ￼. Essentially, it mirrors the training recipe of Hugging Face’s Zephyr, but on a much smaller base model. TinyLlama-1.1B-Chat is optimized for being a helpful chatbot, within the severe size constraints. It’s Apache 2.0 licensed.

Pros:
	•	Ultra-low resource: At just 1.1B params, this model can run almost anywhere – on CPU with <2 GB RAM in 4-bit quant, or on mobile/embedded devices with ease. It’s one of the few models targeting this scale with chat capability.
	•	Massive training for its size: 3T token pretraining is huge relative to model size ￼. This likely imbued it with far more knowledge and linguistic ability than typical 1B models (which often train on 100B or less). It was reported to train for 90 days on 16×A100 GPUs to reach this scale ￼, indicating the thoroughness of training.
	•	Aligned via GPT-4 feedback: The chat fine-tune involved GPT-4’s preference signal (via DPO on UltraFeedback) ￼. This means the model learned not just from raw data but from high-quality AI-generated dialogues and an alignment process. For its size, it likely produces remarkably coherent and polite answers, as well as follows instructions better than any pre-existing 1B model.
	•	Compatibility: Shares architecture with Llama 2, so it benefits from all the same tokenizer, inference optimizations, and can use standard Llama prompting schemes. It’s easily integrated into frameworks expecting a “llama”-style model.
	•	High download count/popularity: It has over a million downloads, suggesting a community has vetted it and found it useful (probably in low-power settings) – an indicator of trust and utility.

Cons:
	•	Limited intelligence and memory: At the end of the day, 1.1B parameters is extremely small for a language model. Expect frequent lapses in knowledge (it will forget or confuse facts easily) and limited reasoning depth. It cannot hold complex chains of thought or multi-step logic reliably. It’s best for very simple tasks or as a novelty where larger models are impossible to run.
	•	Struggles with detailed or technical prompts: It might do okay with casual conversation or very basic questions, but anything requiring in-depth explanation or coding beyond trivial cases will likely be too much. Its performance on coding benchmarks or complicated QA is far below bigger models (there’s no claim it beats larger ones; the focus was on making it usable at all).
	•	May produce unsafe content: The model’s alignment is not as robust as larger RLHF models. The project explicitly notes that removing some alignment (to boost performance) was a technique used (this was noted for Zephyr and the same method was applied here) ￼. Therefore, if prompted maladroitly, it might output problematic or biased content that bigger models might avoid. Always test it for your specific application’s safety needs.
	•	Niche use case: For most users who have access to more resources, a 7B or 13B model will simply do a better job. TinyLlama shines only when you truly cannot run something larger. Its “ceiling” for capability is low, so use it only when model size is the critical factor.

WizardCoder-Python-7B-V1.0 (WizardLM Team)

Summary: WizardCoder-Python-7B is a 7B-parameter model fine-tuned by the WizardLM team for code generation, especially in Python. It originates from Llama 2 (hence the Llama2 license) and was trained on a large collection of high-quality programming prompts and solutions. In particular, WizardCoder-7B achieved 55.5% pass@1 on HumanEval ￼ ￼, which is an excellent result for a 7B model (comparable to some 15B models in coding tasks). It’s essentially a smaller version of the famous WizardCoder 15B/34B models, optimized to be instruction-following and conversational about code. The model uses an Alpaca-style prompt format (“### Instruction: … ### Response:”) and has been tuned to provide helpful, step-by-step answers when needed. It excels at Python coding problems but can handle other languages as well, and can explain code or algorithms on request.

Pros:
	•	High coding proficiency (for 7B): With a 55.5% score on HumanEval ￼, it outperforms CodeLlama-7B and many other 7B code models. It even approaches the performance of larger models, meaning it’s very capable of writing correct code for typical interview-style questions and tasks.
	•	Detailed and instructive responses: As part of the WizardLM family, it was trained on a lot of step-by-step solutions. It often provides explanations or comments along with code, which can be useful for learning or debugging. It’s also adept at multi-turn dialogue – you can ask it to refine or fix code in successive prompts and it will follow along.
	•	Optimized for Python: Python being the focus means it knows the libraries, syntax, and idioms of Python particularly well (e.g., it can use Python standard library or common packages in its suggestions). This makes it an excellent pair programmer for Python developers.
	•	Efficient size: 7B is a sweet spot for many users – runnable on mid-range GPUs or even high-end CPUs with quantization. WizardCoder-7B gives a lot of bang for the buck in that sense, providing near-ChatGPT level code help for a fraction of the compute.
	•	Part of a well-maintained project: WizardLM’s releases are well-documented and have a community. The model card and comparisons show WizardCoder outperforms many rivals on benchmarks ￼ ￼. You’re using a model that’s had some validation from the ML community.

Cons:
	•	Limited general knowledge: While not one-dimensional, the model was heavily tuned on coding QA. For non-coding topics, it might be less knowledgeable than a general 7B like Llama 2 Chat or Mistral Instruct. Its training prioritized programming, so its world knowledge or common sense reasoning might lag behind an equivalent model trained on a broader corpus.
	•	Sometimes overly verbose or formal: The Alpaca-style fine-tuning can lead it to produce a lot of explanatory text. When you just want code, you might have to prompt it to give only the code. Conversely, if you want an explanation, it will gladly produce one. This verbosity is sometimes a drawback if brevity is needed.
	•	Single-turn focus: The prompt format is not a chat with system/user roles but rather a single instruction. While you can have back-and-forth by providing conversation history in the prompt manually, it’s not as naturally a chat model as something like Zephyr or OpenHermes. It doesn’t explicitly have a notion of a system persona or multi-turn state (though it can be cajoled into it).
	•	No explicit long context extension: It uses the base Llama 2 context (4K tokens). This is usually fine for code, but if you wanted to feed in very large code files, you might hit the limit. It doesn’t have the 16K context that CodeLlama did, for instance, so it might require chunking code for very large projects.

Zephyr-7B-Alpha (HuggingFace H4 Team)

Summary: Zephyr-7B-α is a 7B model developed by Hugging Face’s H4 team as a demonstration of alignment techniques. It’s essentially Mistral-7B-v0.1 fine-tuned to be a helpful assistant using Direct Preference Optimization (DPO) on top of high-quality chat datasets ￼ ￼. The training involved first using the UltraChat synthetic dialogues (generated by ChatGPT) and then refining the model with UltraFeedback (64K GPT-4-ranked responses) to directly optimize for helpfulness ￼. The result is a model that ranks very highly on helpfulness benchmarks (it was reported to beat or match GPT-3.5 in some evaluations like MT-Bench) while remaining relatively uncensored (the “α” version removed some dataset alignment to boost raw performance) ￼. Zephyr-7B supports an 8192-token context (from Mistral) and is MIT licensed. It’s basically a proof-of-concept that a well-tuned 7B can be as helpful as larger chatbots, though it may produce disallowed content if prompted (since it doesn’t have a final RLHF guardrail) ￼ ￼.

Pros:
	•	Highly helpful and fluid in dialog: Zephyr was tuned to act as a very helpful assistant. It often gives polite, detailed, and structured answers. In terms of sheer helpfulness and following instructions, it’s among the top for 7B models – the team showed it surpasses some bigger models on MT-Bench (an advanced chat benchmark) ￼.
	•	Good generalist ability: Because it was trained on diverse synthetic dialogues, it can handle casual chatting, brainstorming, explanations, and some coding or math, all in a conversational manner. It blends knowledge and conversational tone well.
	•	Extended context (8K): Having an 8192 token context from the Mistral base is a plus. You can have longer conversations or provide more reference text in your prompt compared to older 7B models limited to 2K or 4K.
	•	Less refusals, more direct answers: Unlike some RLHF models that might refuse queries or give safe-completions frequently, Zephyr tends to answer the question directly (the H4 team intentionally removed some alignment layers to make it more straightforward) ￼ ￼. This can be seen as a pro if you prefer fewer “As an AI, I cannot…” and more actual answers (assuming you use it responsibly).
	•	Open MIT License: Very permissive for integration into any application, including commercial. It’s not often we see such an open license on a high-quality chat model.

Cons:
	•	Safety trade-offs: The flip side of fewer refusals is that Zephyr may output harmful or undesirable content if asked. The team explicitly warns that it can produce problematic text when prompted because it wasn’t thoroughly RLHF-tuned for safety ￼ ￼. So, it requires the user/developer to put guardrails in place if deploying publicly.
	•	Alpha quality: This is an alpha release; it’s essentially the first model in a series. It might have some rough edges or inconsistencies. Future versions (beta, etc.) might be better, but as an initial iteration, expect that it’s not perfect. For example, it might sometimes get confused by system vs. user prompts if not properly formatted (it expects the <|system|>, <|user|>, <|assistant|> tokens as used in training ￼ ￼).
	•	Knowledge cutoff and domain limits: Being based on Mistral 0.1 (which in turn is based on Llama 2’s data circa 2023) means it has no knowledge past 2023 and may miss some niche facts. It’s very good for common knowledge and generic web info, but not specialized in code or specific domains as some other models in the list are.
	•	Benchmark vs real-world gap: While it scored impressively in benchmarks, real user queries can be messier. Users may find that in actual use, it sometimes gives slightly off or hallucinated answers with confidence. This is true of all LLMs, but a 7B will have this more frequently. One should not assume it’s always accurate just because it “beats ChatGPT” on one test; always verify critical outputs.

Command Reference

Use the following commands and tips to manage and utilize the models in this multi-model setup:
	•	Listing Available Models: If using a UI like text-gen-webui, all models placed in the models/ directory will be listed in the dropdown on startup. In a custom script, you might maintain a list of model file paths. Ensure each model has a unique name you can reference. For example, keep directories or filenames like:

models/
 ├── codellama-7b-instruct.Q4_K_M.gguf
 ├── deepseek-coder-6.7b-instruct.Q4_K_M.gguf
 ├── mistral-7b-instruct-v0_2.Q4_K_M.gguf
 └── ... (and so on for all models)

Some UIs require the model file to be named model.gguf inside a folder – follow the UI’s convention. In llama.cpp CLI, you directly use the file name with -m as shown below.

	•	Loading a Model (llama.cpp CLI): Use the -m flag with the path to the GGUF file. Example for loading Zephyr 7B:

./main -m models/zephyr-7b-alpha.Q4_K_S.gguf -c 8192 -n 256 -i -r "</s>"

Here, -i enters interactive mode (so you can type prompts), and -r "</s>" sets an antiprompt to stop generation at an end-of-sentence token (useful for chat). Adjust -c for context length appropriate to the model (Zephyr supports 8192). For 32K context models (Mistral v0.2, Qwen3), use -c 32768 or as needed. The GGUF files include the rope scaling for long context, so llama.cpp will handle it ￼.

	•	Switching Models: In the UI, just select a different model and the new model will be loaded (this might take a few seconds to initialize the weights). In llama.cpp CLI, you need to quit (Ctrl+C or Ctrl+D) and re-run with the new -m path; it does not support hot-swapping models in the same session. If you have a custom multi-model script, ensure it deallocates the previous model before loading another to avoid memory issues.
	•	Downloading Models via CLI: (Recap) Use huggingface-cli download. For example, to download all 4-bit quantizations for these models:

huggingface-cli download TheBloke/CodeLlama-7B-Instruct-GGUF --local-dir ./models --include "*Q4_K*.gguf"
huggingface-cli download TheBloke/Mistral-7B-Instruct-v0.2-GGUF --local-dir ./models --include "*Q4_K*.gguf"
huggingface-cli download TheBloke/OpenHermes-2.5-Mistral-7B-GGUF --local-dir ./models --include "*Q4_K*.gguf"
... # and so on for each repo

Replace Q4_K with the desired quantization if you want smaller/larger files (Q5_K, Q6_K, etc.). The list of model repositories:
	•	TheBloke/CodeLlama-7B-Instruct-GGUF
	•	TheBloke/deepseek-coder-6.7B-instruct-GGUF
	•	TheBloke/Mistral-7B-Instruct-v0.2-GGUF
	•	TheBloke/OpenHermes-2.5-Mistral-7B-GGUF
	•	TheBloke/Phind-CodeLlama-34B-v2-GGUF
	•	unsloth/Qwen3-8B-GGUF
	•	abetlen/replit-code-v1_5-3b-GGUF
	•	tensorblock/starcoder2-3b-GGUF
	•	TheBloke/TinyLlama-1.1B-Chat-v1.0-GGUF
	•	TheBloke/WizardCoder-Python-7B-V1.0-GGUF
	•	TheBloke/zephyr-7B-alpha-GGUF

	•	Prompting Guidance: Refer to the Available Models section for each model’s expected format. Here’s a quick reference:
	•	CodeLlama, Mistral Instruct, DeepSeek: Use [INST] ... [/INST] around user prompt, and the model will output between it and the closing tag.
	•	OpenHermes: It’s flexible; you can use a Role-play system or just ask directly. (It was trained with ChatML, but simple prompts work too.)
	•	Phind-CodeLlama: Use it like an instruct model (it follows Alpaca-style prompt by default). E.g., “### Instruction:\nYour request\n### Response:” as format.
	•	Qwen-8B: Default to normal mode (thinking mode on) and just ask; it will produce reasoning and answer. If integrated via Transformers, use enable_thinking=True in the chat template call ￼.
	•	Replit & StarCoder2: Provide code context or a comment. E.g., for StarCoder2, start with a prompt like: # Python function to check prime\ndef is_prime(n): and let it complete.
	•	TinyLlama & Zephyr: Use a chat format. If using Transformers’ pipeline as in their examples, you can utilize the built-in chat template (system/user roles) ￼ ￼. In a UI, pick a chat preset (like Vicuna format) and it will work.
	•	WizardCoder: Use Alpaca single-turn. E.g., “### Instruction:\nExplain the code below…\n### Response:\n”.
	•	Adjusting Generation Settings: Common parameters:
	•	--temp (temperature): higher for more creative/random output, lower for focused deterministic output. For coding, a lower temperature (0.2–0.5) is often good to get deterministic correct answers ￼; for chat, ~0.7 is a good default.
	•	--top_p and --top_k: these control sampling diversity. Defaults (top_p 0.95, top_k 40) are fine generally.
	•	--repeat_penalty: important to avoid models looping. 1.1 to 1.2 is a common range. We used 1.1 in examples.
	•	-n <tokens> or --max_new_tokens: to limit the length of generation. Use this to prevent extremely long outputs, especially with large context models that might otherwise keep going. For instance, if Phind-34B is writing a full program, you might allow 500 tokens; but for a short answer, limit to 100.
	•	-i (interactive) vs -p (prompt): in llama.cpp, -p runs one prompt and exits, whereas -i lets you have a conversation. Use -i for an interactive session where you can ask multiple questions sequentially (just remember to include an end-of-prompt token or use --instruct mode depending on the build).
	•	Memory Offloading (GPU): If you have a GPU, you can use -ngl <n> in llama.cpp to offload that many layers to GPU (or use gpu_layers in llama-cpp-python). For example, -ngl 32 offloads 32 layers. This can greatly speed up generation for larger models if you have the VRAM (each layer of 7B ~ 100MB, 34B ~ 400MB in 4-bit). Experiment with values to fit your GPU. If you encounter CUDA OOM, lower the number.
	•	Troubleshooting:
	•	If a model fails to load with an error about unknown architecture or tokenization (e.g., 'mistral' is not recognized or 'qwen3' not found), update your software. This is a common issue if transformers or llama.cpp is outdated for new model types ￼ ￼.
	•	If outputs are truncated or seem to stop mid-sentence, increase -n (max tokens) or adjust stopping criteria (the -r antiprompt in llama.cpp can help stop at a specific token, but if it triggers too early it might cut off text – for chat models, using </s> as antiprompt is standard to stop on end-of-response).
	•	For quality issues: ensure you’re using the right prompt format for the model. A common mistake is using a chat format on a completion model or vice versa. Double-check the Available Models notes and try formatting accordingly. Small tweaks in phrasing (“Explain how X works.” vs “Describe the process of X.”) can sometimes yield better results from instruct models, so don’t hesitate to experiment.

By following this guide, you can effectively utilize each of the listed models in your local environment. Happy prompting and coding!