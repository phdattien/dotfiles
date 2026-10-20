# dotfiles

## Linux install (Neovim + tmux only)
    git clone https://github.com/phdattien/dotfiles.git ~/dotfiles
    cd ~/dotfiles && ./install.sh

Installs Neovim 0.10.4, tmux and what they need, links `config/nvim` -> `~/.config/nvim`,
`linux/tmux.conf` -> `~/.tmux.conf`, and installs all plugins pinned to the exact
commits used on the Mac (see `config/nvim/lua/theprimeagen/packer.lua`).
Re-runnable; existing files are renamed to `*.bak.<timestamp>`.
Top-level dotfiles (`.zshrc`, `.tmux.conf`, ...) are the Mac versions and are not used.
