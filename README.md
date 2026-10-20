# dotfiles

## Linux install
    git clone git@github.com:phdattien/dotfiles.git ~/dotfiles   # or the https URL
    cd ~/dotfiles && ./install.sh

Needs internet + sudo; supports apt / dnf / pacman; re-runnable.
Existing files are renamed to `*.bak.<timestamp>`. Config is symlinked into this
clone, so keep the folder and `git pull` to update.

- `config/nvim`, `config/htop`: symlinked to `~/.config/`
- `linux/`: tmux.conf (no theme plugin), tmux-sessionizer, gitconfig for the Linux box
- Top-level dotfiles (`.tmux.conf`, `.zshrc`, `.gitconfig`, ...) are the Mac versions and are not used by `install.sh`
