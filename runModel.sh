#!/bin/bash
# Stephanos B 27/04/2025

# Script to run LLMs through Llama.cpp

    # The terminal is running in the directory with the model already
     # cd /path/to/model_directory
     # ./runModel.sh "my prompt"
    #

    # The paths are specified:
     # ./llama_deploy.sh -i "my_config.txt" -p "A Test prompt for simple usage"
     # ./llama_deploy.sh -i "./Example_1" -s "./custom-sys.txt" -c ""./chatlog.txt" -p "A prompt for a full usage exmaple"
    #
#

### Global Variables {{{

    CONFIG_FILE="./inits/Example.config"
    CHAT_LOG_FILE="./chatlog.txt"
    
    user_prompt="null"
    sys_prompt_path="./sys.txt" # Is sourced from config file

    # Tempory, will do this better last
    USAGE="Usage: $(basename $0) [-i path/init.config] [-s path/Chatlog.txt] [-c path/Chatlog.txt] [-p \"prompt\"] { R|run | S|server}"

### }}}

# Runs the given init.config in the CLI
runPrompt() {  
    local sys_prompt="$(cat "$sys_prompt_path")"
    
    # Adds the new prompt to the chatlog
    echo "\\n<|im_start|>user" >> "$CHAT_LOG_FILE"
    echo "$user_prompt<|im_end|>\\n" >> "$CHAT_LOG_FILE"
    local chat_history="$(cat "$CHAT_LOG_FILE")"

    # Format for Qwen/DeepSeek
    prompt="${chat_history}" # The new prompt is already baked into the chat-log

    #echo -e "Final Prompt:\n${prompt}" # Debug #
    llama-cli -m "$model_path" -t "$threads" -ngl "$GPU_offload" --temp "$temperature" -c "$context_leng" -sys "$sys_prompt" -p "$prompt" --escape --color | tee "./temp.txt" # Run inference

    # Appends response to chat-log
     # If the variable `logicPhrase` is present in the .config file then only after the phrase of it's value is found will the response be recorded
    if [ -n "$logicPhrase" ]; then  
        model_reply=$(awk -v trigger="$logicPhrase" 'BEGIN { found=0 } $0 ~ trigger { found=1; next } found { print }' temp.txt)  
        
        else  
            model_reply=$(cat temp.txt)  
    fi  
    echo "<|im_start|>assistant" >> "$CHAT_LOG_FILE"
    echo "$model_replay<|im_end|>" >> "$CHAT_LOG_FILE"
} # runPrompt()

# Starts the given init.config as a server
runServer() {
    llama-server -m "$model_path" -t "$threads" -ngl "$GPU_offload" --temp "$temperature" -c "$context_leng" # Launch inference server
} # runServer()


### Main Execution {{{
    # Parse flags
    while getopts ':i:s:c:p:h' opt; do
    case "$opt" in
        #Init (config) file
        i)
            arg="$OPTARG"
            echo "init file location at '${OPTARG}'"
            CONFIG_FILE="$arg"
            ;;

        # System-prompt file
        s)
            arg="$OPTARG"
            echo "system-prompt file location at '${OPTARG}'"
            sys_prompt_path="$arg"
            ;;

        # Chat-log file
        c)
            arg="$OPTARG"
            echo "chat-log file location at '${OPTARG}'"
            CHAT_LOG_FILE="$arg"
            ;;

        # Prompt
        p)
            arg="$OPTARG"
            echo "Prompy included '${OPTARG}'"
            user_prompt="$arg"
            ;;

        
        ### other ###
        h)
            echo "$USAGE"
            exit 0
            ;;

        :)
            echo -e "option requires an argument.\n$USAGE"
            exit 1
            ;;

        ?)
            echo -e "Invalid command option .\n$$USAGE"
            exit 1
            ;;
        esac
    done
    shift "$(($OPTIND -1))"


    ## Checks if config file is found {{
        [ ! -f "./$CONFIG_FILE" ] && {
            echo "Error: Config file '$CONFIG_FILE' not found!" >&2
            exit 2
        } # If the file does not exist then it stops
        source "$CONFIG_FILE" || exit 1 # Loads values from file

        [ ! -f "$sys_prompt_path" ] && {
            echo "Error: System Prompt file '$sys_prompt_path' not found!" >&2
            exit 2
        }

        [ ! -f "$CHAT_LOG_FILE" ] && {
            echo "Error: System Prompt file '$CHAT_LOG_FILE' not found!" >&2
            exit 2
        }

    ## }}

    # Checks what mode the augs are for
    case "$1" in
        
        #
        R|run)
            #
            if [ "$user_prompt" == "null" && f "./prompt.txt" ]; then
                user_prompt="$(cat "./prompt.txt")"
                else
                    # If there is no prompt passed then ask for it
                        # This can maybe clean up the usage, only specifying config params then the command asks for prompts. Would make it easy to run in a loop
                    read -p "Enter Prompt: " user_prompt
            fi
            runPrompt
        ;;

        #
        S|server)
            #
            runServer
        ;;

        # redundant?
        *)
            echo "Switch $1 : $USAGE"
        ;;
    esac # case $1

### Main Execution }}}

exit $?
