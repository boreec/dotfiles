# dotfiles

This repository is a collection of configuration files that I use across my 
systems. It is not intended to be easy to use for all, but to serve as a 
backup in case of a new OS setup/upgrade.

Still, I encourage anyone to explore this repository and use these files as a 
reference for your own configuration files.

## Setup

Move to your home directory, create an empty git repository, set the remote
to this repository and pull.

```console
cd ~
git init .
git remote add origin https://github.com/boreec/dotfiles.git
git pull origin main
```

## Applications

- commands:
  - [git](https://git-scm.com/)
  - [zoxide](https://github.com/ajeetdsouza/zoxide)
- editor:
  - [helix](https://github.com/helix-editor/helix) 
- shell:
  - [starship](https://github.com/starship/starship) 
  - zsh
- terminal:
  - [alacritty](https://github.com/alacritty/alacritty)
  - [zellij](https://github.com/zellij-org/zellij)
- web-browser:
  - [firefox](https://www.mozilla.org/en-US/firefox/new/)

## LSPs

- [bash-language-server](https://github.com/bash-lsp/bash-language-server) (bash)
- [marksman](https://github.com/artempyanykh/marksman) (markdown)
- [pylsp](https://github.com/python-lsp/python-lsp-server) (python)
- [ruff-lsp](https://github.com/astral-sh/ruff-lsp) (python)
- [rust-analyzer](https://github.com/rust-lang/rust-analyzer) (rust)
- [taplo](https://github.com/tamasfe/taplo) (toml)
- [typescript-language-server](https://github.com/typescript-language-server/typescript-language-server) (typescript)
- [rustfmt](https://github.com/rust-lang/rustfmt) (rust)
- [pre-commit](https://pre-commit.com/)
