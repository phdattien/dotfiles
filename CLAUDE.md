# CLAUDE.md

Personal dotfiles for Pham Tien Dat (GitHub: `phdattien/dotfiles`, cloned to `~/.dotfiles`).

## Layout
- `bootstrap` — entry point (macOS + Linux). Steps: `packages tools link plugins shell`; idempotent. Linux gets Neovim v0.12.6 in `/opt`; macOS uses brew.
- `stow/<package>/` mirrors `$HOME` and is linked with `stow --no-folding`: `zsh`, `tmux`, `git`, `nvim` (`.config/nvim`), `claude` (`.claude/{skills,commands,agents}` only), `htop` (opt-in).
- `packages/{brew,apt,dnf,pacman}.txt` — package lists, one per line.
- Neovim config: `lua/theprimeagen/{init,set,remap,packer}.lua`, per-plugin setup in `after/plugin/*.lua`. `packer.lua` pins every plugin to a commit and is NOT required from `init.lua`; `bootstrap` loads it explicitly to define `:PackerSync`.
- Per-machine, untracked, sourced/included by the tracked files: `~/.zshrc.local`, `~/.gitconfig.local`, `~/.gitconfig-CVUT`.

## Conventions
- Keep `bootstrap` idempotent; package failures warn, missing core tools abort.
- When changing plugins, update the pinned commit in `packer.lua`.
- Never commit secrets, API keys or tokens (they were removed earlier on purpose). Flag any that appear (e.g. URLs/keys in `.zshrc`).
- `stow/zsh/.zshrc` is shared across OSes: guard OS- or tool-specific lines (`case $(uname)`, existence checks). Anything machine-specific or secret goes in `~/.zshrc.local`, never in the repo.
- Never use `.tmux/plugins`-style vendored plugin dirs; tpm installs tmux plugins.
- Commit messages: short imperative sentence, matching existing history ("Install uv", "Pin plugin commits").

## Testing changes
- Neovim: `nvim --headless -c 'quitall'` must exit cleanly.
- Bootstrap: `bash -n bootstrap`, then test Linux in a clean container, e.g. `docker run --rm -v "$PWD":/src:ro ubuntu:24.04 bash -c 'apt-get update -qq && apt-get install -y -qq git && cp -r /src /root/.dotfiles && /root/.dotfiles/bootstrap'`. Don't test linking by running it on the main machine unless you want the files replaced (backups go to `~/.dotfiles-backup-*`).
