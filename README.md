# llamaCpp_automateRunner_Bash
A simple Bash script to make running Llama.cpp simpler and easier to deploy across various models and configurations

### Why would you use this?
This lets you use llama.cpp CLI in a cleaner format where you can pre-configure multiple models, system-prompts and persistent chats automatically.
All you MUST do is specifiy which init.config file to load everything else is auto unless you want to specify otherwise.
This makes it very clean since you don't need to worry about adding the model-path, deployment settings, system-prompt, and *entire chat history* ontop of your prompt.

---

# Featurse
Loads a model from a init.config file where you specficy the various deployment parameters of the model.
Currenlty is desinged to support DeepSeek and Qwen style chat-history.
Chat history is written to a file and formated for the model. This is for when using the model with the CLI

## Build an init.config file:
This file is the deployment or initialization file. It contains all the settings of the model and its file-path.
This file needs to follow the same format as Bash for variable declaration, so no spaces between the value and the '=' sign.

Example of an Init.config file for deploying DeepSeek-V3 (Unsloth)
~~~.config
# paths
model_path="/home/USER/LLM_Models/models/unsloth/DeepSeek-V3-0324-GGUF/DeepSeek-V3-0324-UD-IQ1_S-00001-of-00004.gguf" # This is just the path to the model
prompt_temp_path="./deep_seek_2.txt" # !!This is currently unused!!
sys_prompt_path="./sys.txt"

# Load
context_leng=4000
GPU_offload=2
threads=11
evaluativeBatch=1024
mmap=true
#experts=5 # !!Not implemented yet!!

# Inferance
temperature=0.455

  # This is used as a delimeter, everything in the model response prior to this is not recorded in the chat-log, so in practice this makes the chat exclude the <think> block of the model.
  # This is 100% optional! If you want the model to remember its own thoughts then you can be removing this.
  # If not require then you can delete this line, I've commented it out to show it in this example, as DeepSeekV3 won't need this
#logicPhrase="/think"
~~~

---

## Usage:

Once you have a init.config file ready only then can you use the script.
Creating a system-prompt, chatlog and prompt file are all optional.

```.sh
Usage: ./runModel.sh
R|run                      | Runs in the CLI
  [-i path/init.config]    | The model init file to load (required)
  [-s path/sys.txt]        | System-prompt source file
  [-c path/Chatlog.txt]    | The chat history file to load and write to
  [-p \"prompt\"]          | Initial prompt. If blank then a prompt.txt file will be loaded if present. If not then the console will as for a prompt

S|server                   | Runs the built-in server loaded with the chosen model
  [-i path/init.config]    | The model init file to load (required)
```
