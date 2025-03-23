
function Build-LlamaCpp {

    Invoke-Expression "zsh -c 'llama-cli --completion-bash > ~/.llama-completion.bash'"
    Invoke-Expression "zsh -c 'source ./.llama-completion.bash'"    
    Invoke-Expression "cd ~ && git clone https://github.com/ggml-org/llama.cpp.git"
    Invoke-Expression "zsh -c 'sudo apt-get install cmake'"
    Invoke-Expression "zsh -c 'cmake -B build -DGGML_CUDA=ON'"
    Invoke-Expression "cmake --build build --config Release"
}
function Start-Gemma3LlamaCpp {

    Invoke-Expression "llama-server -m $env:HOME/.ollama/models/gemma-3-12b-it-Q4_K_M.gguf -c 16384 -t 4 --flash-attn -ngl 32 -ngld 64 --prio-batch 2 --temp 0.8 --top-k 64 --batch-size 16384 --ubatch-size 4096"
}

