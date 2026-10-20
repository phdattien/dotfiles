#!/usr/bin/env bash
# Installs Neovim + deps and links this config on a Linux machine. Safe to re-run.
set -euo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SUDO=""; [[ $EUID -ne 0 ]] && SUDO="sudo"
NVIM_VERSION="v0.10.4"
log() { printf '\n\033[1;34m==> %s\033[0m\n' "$*"; }

# ---------- 1. system packages ----------
log "Installing system packages"
if command -v apt-get >/dev/null; then
    $SUDO apt-get update
    $SUDO apt-get install -y git curl wget unzip tar gcc g++ make ripgrep fd-find fzf tmux htop xclip nodejs npm python3 python3-venv zsh
elif command -v dnf >/dev/null; then
    $SUDO dnf install -y git curl wget unzip tar gcc gcc-c++ make ripgrep fd-find fzf tmux htop xclip nodejs npm python3 zsh
elif command -v pacman >/dev/null; then
    $SUDO pacman -Sy --needed --noconfirm git curl wget unzip tar gcc make ripgrep fd fzf tmux htop xclip nodejs npm python zsh
else
    echo "Unknown package manager; install git curl gcc make ripgrep fzf tmux nodejs npm manually, then re-run." >&2
    exit 1
fi

# ---------- 2. Neovim (need >= 0.9) ----------
nvim_ok() { command -v nvim >/dev/null && nvim --version | head -1 | grep -qE 'v0\.(9|1[0-9])|v[1-9]'; }
if ! nvim_ok; then
    log "Installing Neovim $NVIM_VERSION"
    arch="$(uname -m)"
    if [[ "$arch" == "x86_64" ]]; then
        tmp="$(mktemp -d)"
        curl -fL "https://github.com/neovim/neovim/releases/download/$NVIM_VERSION/nvim-linux64.tar.gz" -o "$tmp/nvim.tar.gz"
        $SUDO rm -rf /opt/nvim-linux64
        $SUDO tar -C /opt -xzf "$tmp/nvim.tar.gz"
        $SUDO ln -sf /opt/nvim-linux64/bin/nvim /usr/local/bin/nvim
        rm -rf "$tmp"
    else
        echo "Non-x86_64 CPU: installing neovim from package manager." >&2
        if command -v apt-get >/dev/null; then $SUDO apt-get install -y neovim
        elif command -v dnf >/dev/null; then $SUDO dnf install -y neovim
        else $SUDO pacman -S --needed --noconfirm neovim; fi
    fi
fi
nvim --version | head -1

# fd is called fdfind on Debian/Ubuntu
mkdir -p "$HOME/.local/bin"
if command -v fdfind >/dev/null && ! command -v fd >/dev/null; then ln -sf "$(command -v fdfind)" "$HOME/.local/bin/fd"; fi

# ---------- 3. link config (existing files are backed up) ----------
link() { # link <src> <dest>
    local src="$1" dest="$2"
    mkdir -p "$(dirname "$dest")"
    if [[ -e "$dest" || -L "$dest" ]] && [[ "$(readlink -f "$dest")" != "$(readlink -f "$src")" ]]; then
        mv "$dest" "$dest.bak.$(date +%s)"; echo "backed up $dest"
    fi
    ln -sfn "$src" "$dest"; echo "linked $dest -> $src"
}
log "Linking config"
link "$HERE/config/nvim"  "$HOME/.config/nvim"
link "$HERE/config/htop"  "$HOME/.config/htop"
link "$HERE/linux/tmux.conf"    "$HOME/.tmux.conf"
link "$HERE/linux/zshrc"       "$HOME/.zshrc"
mkdir -p "$HOME/.scripts"
link "$HERE/linux/tmux-sessionizer" "$HOME/.scripts/tmux-sessionizer"
link "$HERE/linux/tmux-sessionizer" "$HOME/.local/bin/tmux-sessionizer"
# gitconfig: don't clobber an existing one
if [[ ! -e "$HOME/.gitconfig" ]]; then link "$HERE/linux/gitconfig" "$HOME/.gitconfig"
else echo "~/.gitconfig exists, leaving it (see $HERE/linux/gitconfig for aliases)"; fi
mkdir -p "$HOME/.vim/undodir"

case ":$PATH:" in *":$HOME/.local/bin:"*) ;; *)
    echo 'export PATH="$HOME/.local/bin:$PATH"' >> "$HOME/.profile"
    echo 'added ~/.local/bin to PATH in ~/.profile (re-login to apply)';;
esac

# ---------- 4. tmux plugin manager ----------
log "Installing tpm + tmux plugins"
[[ -d "$HOME/.tmux/plugins/tpm" ]] || git clone --depth 1 https://github.com/tmux-plugins/tpm "$HOME/.tmux/plugins/tpm"
"$HOME/.tmux/plugins/tpm/bin/install_plugins" || echo "tmux plugin install failed (non-fatal)"

# ---------- 5. Neovim plugins (packer) ----------
log "Installing Neovim plugins"
PACKER="$HOME/.local/share/nvim/site/pack/packer/start/packer.nvim"
[[ -d "$PACKER" ]] || git clone --depth 1 https://github.com/wbthomason/packer.nvim "$PACKER"
# first run errors because plugins are missing; that's expected
nvim --headless -c 'autocmd User PackerComplete quitall' -c 'PackerSync' || true
# install treesitter parsers
nvim --headless -c 'TSUpdateSync' -c 'quitall' || true
# second pass to confirm a clean startup
nvim --headless -c 'quitall' && echo "Neovim starts cleanly."

# ---------- 6. zsh + oh-my-zsh ----------
log "Setting up zsh + oh-my-zsh"
if [[ ! -d "$HOME/.oh-my-zsh" ]]; then
    RUNZSH=no CHSH=no KEEP_ZSHRC=yes sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
fi
if [[ "$(basename "${SHELL:-}")" != "zsh" ]]; then
    chsh -s "$(command -v zsh)" || echo "chsh failed; run: chsh -s $(command -v zsh)"
fi

# ---------- 7. uv ----------
log "Installing uv"
command -v uv >/dev/null || curl -LsSf https://astral.sh/uv/install.sh | sh

log "Done. Open a new terminal, run 'nvim'. Set your terminal font to a Nerd Font for icons."
echo "Supermaven: run :SupermavenUseFree (or log in) inside nvim on first start."
