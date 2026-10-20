#!/usr/bin/env bash
# Sets up Neovim (same plugins/versions as the Mac) and tmux on a Linux machine.
# Safe to re-run. Existing files are renamed to *.bak.<timestamp>.
set -uo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SUDO=""; [[ $EUID -ne 0 ]] && SUDO="sudo"
NVIM_VERSION="v0.10.4"
log()  { printf '\n\033[1;34m==> %s\033[0m\n' "$*"; }
warn() { printf '\033[1;33mWARN: %s\033[0m\n' "$*" >&2; }

# ---------- 1. packages (a failure here is not fatal) ----------
log "Installing packages: git curl tmux ripgrep fzf gcc make unzip xclip nodejs npm"
if command -v apt-get >/dev/null; then
    $SUDO apt-get update || warn "apt-get update failed"
    $SUDO apt-get install -y --no-install-recommends git curl ca-certificates tar unzip gcc g++ make ripgrep fzf tmux xclip nodejs npm \
        || warn "apt install failed. If it mentions linux-image/dpkg, fix with: sudo dpkg --configure -a && sudo apt-get -f install, then re-run"
elif command -v dnf >/dev/null; then
    $SUDO dnf install -y git curl tar unzip gcc gcc-c++ make ripgrep fzf tmux xclip nodejs npm || warn "dnf install failed"
elif command -v pacman >/dev/null; then
    $SUDO pacman -S --needed --noconfirm git curl tar unzip gcc make ripgrep fzf tmux xclip nodejs npm || warn "pacman install failed"
else
    warn "Unknown package manager; install git curl gcc make ripgrep fzf tmux nodejs npm manually."
fi
for c in git curl gcc make tmux; do command -v "$c" >/dev/null || { echo "ERROR: '$c' is missing, install it and re-run." >&2; exit 1; }; done

# ---------- 2. Neovim (need >= 0.10) ----------
nvim_ok() { command -v nvim >/dev/null && nvim --version | head -1 | grep -qE 'v0\.1[0-9]|v[1-9]'; }
if ! nvim_ok; then
    log "Installing Neovim $NVIM_VERSION"
    if [[ "$(uname -m)" == "x86_64" ]]; then
        tmp="$(mktemp -d)"
        curl -fL "https://github.com/neovim/neovim/releases/download/$NVIM_VERSION/nvim-linux64.tar.gz" -o "$tmp/nvim.tar.gz" \
            || { echo "ERROR: could not download Neovim" >&2; exit 1; }
        $SUDO rm -rf /opt/nvim-linux64
        $SUDO tar -C /opt -xzf "$tmp/nvim.tar.gz" || exit 1
        $SUDO ln -sf /opt/nvim-linux64/bin/nvim /usr/local/bin/nvim
        rm -rf "$tmp"
    else
        warn "Not x86_64: installing Neovim from the package manager (may be older than 0.10)"
        if command -v apt-get >/dev/null; then $SUDO apt-get install -y neovim
        elif command -v dnf >/dev/null; then $SUDO dnf install -y neovim
        else $SUDO pacman -S --needed --noconfirm neovim; fi
    fi
fi
hash -r
command -v nvim >/dev/null || { echo "ERROR: nvim not installed" >&2; exit 1; }
nvim --version | head -1

# ---------- 3. link config ----------
link() { # link <src> <dest>
    local src="$1" dest="$2"
    mkdir -p "$(dirname "$dest")"
    if [[ -e "$dest" || -L "$dest" ]] && [[ "$(readlink -f "$dest")" != "$(readlink -f "$src")" ]]; then
        mv "$dest" "$dest.bak.$(date +%s)"; echo "backed up $dest"
    fi
    ln -sfn "$src" "$dest"; echo "linked $dest -> $src"
}
log "Linking config"
link "$HERE/config/nvim"            "$HOME/.config/nvim"
link "$HERE/linux/tmux.conf"        "$HOME/.tmux.conf"
link "$HERE/linux/tmux-sessionizer" "$HOME/.scripts/tmux-sessionizer"
chmod +x "$HERE/linux/tmux-sessionizer"
mkdir -p "$HOME/.vim/undodir"   # persistent undo dir used by set.lua

# ---------- 4. tmux plugin manager ----------
log "Installing tpm + tmux plugins"
[[ -d "$HOME/.tmux/plugins/tpm" ]] || git clone --depth 1 https://github.com/tmux-plugins/tpm "$HOME/.tmux/plugins/tpm"
"$HOME/.tmux/plugins/tpm/bin/install_plugins" || warn "tmux plugin install failed (non-fatal)"

# ---------- 5. Neovim plugins (packer, pinned to the Mac's versions) ----------
log "Installing Neovim plugins (takes a few minutes)"
PACKER="$HOME/.local/share/nvim/site/pack/packer/start/packer.nvim"
[[ -d "$PACKER" ]] || git clone --depth 1 https://github.com/wbthomason/packer.nvim "$PACKER"
# packer.lua is not required from init.lua, so load it explicitly (this defines :PackerSync).
# Errors printed on this first run are expected: the plugins are not installed yet.
timeout 900 nvim --headless -c "lua require('theprimeagen.packer')" \
    -c 'autocmd User PackerComplete quitall' -c 'PackerSync' \
    || warn "PackerSync did not finish cleanly; open nvim and run :PackerSync"
echo
# treesitter parsers
timeout 600 nvim --headless -c 'TSUpdateSync' -c 'quitall' || true
echo
nvim --headless -c 'quitall' && echo "Neovim starts."

log "Done. Run 'nvim' (first start may install LSP servers via Mason) and 'tmux'."
echo "Supermaven: run :SupermavenUseFree (or log in) inside nvim on first start."
echo "In tmux, press prefix (Ctrl-a) then I to fetch tmux plugins if any are missing."
