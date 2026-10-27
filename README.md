# dotfiles

macOS and Linux (apt/dnf/pacman). zsh, tmux, git, Neovim and Claude Code config, one command.

    git clone https://github.com/phdattien/dotfiles.git ~/.dotfiles && ~/.dotfiles/bootstrap

`bootstrap` installs packages, Neovim 0.12 (Linux), oh-my-zsh and uv, symlinks configs with
[GNU Stow](https://www.gnu.org/software/stow/), then syncs tmux and Neovim plugins (pinned commits).
Re-runnable. Real files that would be replaced are moved to `~/.dotfiles-backup-<timestamp>/`.

Run single steps: `./bootstrap link` (steps: `packages tools link plugins shell`).

## Layout
`stow/<package>/` mirrors `$HOME`: `zsh`, `tmux`, `git`, `nvim`, `claude`, `htop` (not linked by default;
htop rewrites its config file, so link it with `PACKAGES=htop ./bootstrap link` if you want it).
`packages/*.txt` are the package lists per package manager.

## Per-machine files (untracked, created or edited by hand)
- `~/.zshrc.local` — secrets and machine-specific env vars
- `~/.gitconfig.local` — `user.name`, `user.email`, url rewrites (bootstrap asks on first run)
- `~/.gitconfig-CVUT` — included automatically for repos under `~/CVUT/`

## Adding things
- New dotfile: put it under `stow/<package>/` at its path relative to `$HOME`, run `./bootstrap link`.
- Claude Code skill/command/agent: add it under `stow/claude/.claude/{skills,commands,agents}/`, commit, run `./bootstrap link` on each machine.
  Only those paths are linked, never all of `~/.claude` (it holds history and credentials).
