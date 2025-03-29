
function Build-LlamaCpp {

    Invoke-Expression "zsh -c 'llama-cli --completion-bash > ~/.llama-completion.bash'"
    Invoke-Expression "zsh -c 'source ./.llama-completion.bash'"    
    Invoke-Expression "cd ~ && git clone https://github.com/ggml-org/llama.cpp.git"
    Invoke-Expression "zsh -c 'sudo apt-get install cmake'"
    Invoke-Expression "zsh -c 'cmake --fresh -B build -DGGML_CUDA=ON -GGML_CUDA_FORCE_CUBLAS=ON -GGML_CUDA_FORCE_MMQ=ON'"
    Invoke-Expression "cmake --build build --config Release"
}
function Start-Gemma3LlamaCpp {

    Invoke-Expression "llama-server -m $env:HOME/.ollama/models/gemma-3-12b-it-Q4_K_M.gguf -c 8192 -t 12 -ngl 36 -ngld 128 --flash-attn --prio-batch 2 --temp 0.8 --top-k 64 --batch-size 8192 --ubatch-size 4096 --threads-http 8 --main-gpu 0"
}

