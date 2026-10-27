# Shared by macOS and Linux. Machine-specific bits and secrets go in ~/.zshrc.local (untracked).
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="robbyrussell"
plugins=(git)
[ -f "$ZSH/oh-my-zsh.sh" ] && source "$ZSH/oh-my-zsh.sh"

export PATH="$HOME/.local/bin:$PATH"
export EDITOR='nvim'
alias nv='nvim'
alias cl='clear'
alias py='python3'
alias cvut='cd ~/CVUT/; tmux'

case "$(uname)" in
    Darwin)
        [ -x /opt/homebrew/bin/brew ] && eval "$(/opt/homebrew/bin/brew shellenv)"
        [ -d "$HOME/Library/Python/3.9/bin" ] && export PATH="$HOME/Library/Python/3.9/bin:$PATH"
        ;;
    Linux)
        command -v rfkill >/dev/null && rfkill unblock bluetooth 2>/dev/null
        if [ -d /usr/local/cuda ]; then
            export CUDA_HOME=/usr/local/cuda
            export PATH="/usr/local/cuda/bin${PATH:+:${PATH}}"
            export LD_LIBRARY_PATH="/usr/local/cuda/lib64${LD_LIBRARY_PATH:+:${LD_LIBRARY_PATH}}"
        fi
        ;;
esac

# conda (only if installed)
for d in "$HOME/miniconda3" "$HOME/anaconda3"; do
    if [ -x "$d/bin/conda" ]; then eval "$("$d/bin/conda" shell.zsh hook 2>/dev/null)"; break; fi
done

# pyenv (only if installed)
export PYENV_ROOT="$HOME/.pyenv"
if [ -d "$PYENV_ROOT" ]; then
    export PATH="$PYENV_ROOT/bin:$PATH"
    eval "$(pyenv init -)"
fi

[ -f "$HOME/.zshrc.local" ] && source "$HOME/.zshrc.local"
