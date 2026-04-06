# Ubuntu Development Environment Setup

A reproducible, idempotent setup for a modern Ubuntu-based development environment.

This repository provides a layered, script-driven approach to configuring a Linux system for software development, with a focus on:

* reproducibility
* minimal manual intervention
* clean separation of concerns
* fast rebuilds (local, WSL, or fresh machines)

---

## Overview

The setup is divided into **three independent layers**:

| Layer          | Script      | Purpose                                                              |
| -------------- | ----------- | -------------------------------------------------------------------- |
| Base system    | `base.sh`   | Installs core packages, removes snap, configures system dependencies |
| Environment    | `env.sh`    | Sets up dotfiles, shell environment, SSH, and Git                    |
| Python tooling | `python.sh` | Installs `uv`, manages Python versions, and installs dev tools       |

All layers are **idempotent** — you can safely rerun them at any time.

---

## Quick Start

```bash
sudo apt update
sudo apt install -y git

git clone https://github.com/Kylef94/ubuntu-setup.git
cd ubuntu-setup

./setup.sh
```

This will run all setup layers.

---

## Usage

### Default (recommended)

```bash
./setup.sh
```

Runs:

* base system setup
* environment + dotfiles
* Python + `uv` tooling

---

### Selective setup

Skip specific layers:

```bash
./setup.sh -np     # skip Python setup
./setup.sh -nb     # skip base system
./setup.sh -ne     # skip environment setup
```

Combine flags:

```bash
./setup.sh -nb -ne   # run Python only
```

---

### Interactive mode

```bash
./setup.sh -i
```

Prompts you to select which layers to run.

---

### Environment variables

You can configure parts of the setup non-interactively:

```bash
GIT_NAME="Your Name" \
GIT_EMAIL="you@example.com" \
PYTHON_VERSION="3.14.3" \
./setup.sh
```

Supported variables:

| Variable         | Description                       |
| ---------------- | --------------------------------- |
| `GIT_NAME`       | Git user.name                     |
| `GIT_EMAIL`      | Git user.email                    |
| `PYTHON_VERSION` | Python version installed via `uv` |
| `UV_INSTALL_DIR` | Installation directory for `uv`   |

---

## Project Structure

```text
.
├── base.sh        # system packages and base config
├── env.sh         # dotfiles, shell, SSH, Git
├── python.sh      # Python + uv tooling
├── setup.sh       # orchestrator script
├── common.sh      # shared helper functions
└── dotfiles/      # shell, i3, tmux, etc.
```

---

## Design Principles

### Idempotency

All scripts can be safely re-run. Existing configuration is preserved or updated only when necessary.

---

### Separation of concerns

Each script has a clear responsibility:

* `base.sh` → system-level dependencies
* `env.sh` → user environment
* `python.sh` → language/tooling layer

---

### No hidden side effects

Installers are run in **unmanaged mode** where possible (e.g. `uv`) to avoid modifying shell configuration behind your back.

All environment configuration is explicitly controlled via dotfiles and scripts.

---

### Minimal abstraction

Shell configuration avoids unnecessary wrappers or aliases. Native commands (`uv`, `git`, etc.) are preferred unless there is a clear usability benefit.

---

## Python Setup

Python is managed using `uv`, which provides:

* fast dependency resolution
* isolated tool environments
* Python version management

Installed tools include:

* `ipython`
* `ruff`
* `mypy`

Example usage:

```bash
uv init
uv add numpy pandas
uv run python
```

Convenience aliases:

```bash
py      # uv run python
upip    # uv pip
```

---

## Dotfiles

Dotfiles are stored in `dotfiles/` and symlinked into the home directory.

Examples:

* `~/.zshrc`
* `~/.bashrc`
* `~/.config/i3/config`
* `~/.tmux.conf`

Existing files are backed up on first run.

---

## Rebuilding / Updating

Because everything is idempotent, you can update your environment at any time:

```bash
git pull
./setup.sh
```

---

## Typical Workflows

### Fresh machine

```bash
./setup.sh
```

---

### Update dotfiles only

```bash
./setup.sh -nb -np
```

---

### Reinstall Python tooling

```bash
./setup.sh -nb -ne
```

---

### WSL testing

This setup works well inside WSL for testing before committing to a full dual-boot environment.

---

## Future Improvements

* additional language/tooling layers
* container/devcontainer support
* optional modules (Java, C++, etc.)
* CI validation of scripts

---

## License

MIT License
