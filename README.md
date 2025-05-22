# ✨ dotfiles

This repository is a collection of configuration files that I use across
machines. While I strive to keep it clean and functional, I cannot guarantee
that everything will always work as documented. Use it at your own risk.

- [🚀 How to use](#🚀-how-to-use)
- [📦 Contents](#📦-contents)
- [🔨 Tools](#🔨-tools)
  - [👀 Monitoring](#👀-monitoring)
  - [📝 Text Editing](#📝-text-editing)
  - [🖥️ Terminal](#🖥️-terminal)
  - [⚙️ Utilities](#️-utilities)
  - [🕸️ Web Browsing](#🕸️-web-browsing)
  - [🪟 Window manager](#🪟-window-manager)

## 🚀 How to use

Note: Backup your existing home directory and configuration files before
proceeding.

There are two options for using this repository:

1. Make the home directory track the repository and pull from time to time:

```console
cd
git init .
git remote add origin https://github.com/boreec/dotfiles.git
git pull origin main
```

2. Clone the repository elsewhere and copy only the files needed for a safer
   approach:

```console
cd /tmp
git clone https://github.com/boreec/dotfiles.git
cd dotfiles
cp -R .config/tmux ~/.config/tmux
```

---

## 📦 Contents

```text
.
├── .config         # The main config folder
│   ├── alacritty   # Config for alacritty
│   ├── helix       # Config for helix: deprecated in favor of neovim
│   ├── nvim        # Config neovim: nvim-config git submodule
│   ├── ruff        # Config for ruff
│   ├── rustfmt     # Config for rustfmt
│   ├── tmux        # Config for tmux
│   └── zellij      # Config for zellij: deprecated in favor of tmux
├── .hammerspoon    # Config for hammerspoon
├── scripts         # Homemade scripts
├── .zsh_aliases    # Useful command aliases
├── .zshrc          # Common .zshrc
└── README.md       # You are here
```

## 🔨 Tools

Below is a list of tools I use regularly.

### 👀 Monitoring

- [bottom](https://github.com/ClementTsang/bottom)
- [btop](https://github.com/aristocratos/btop)

### 📝 Text Editing

- [helix](https://github.com/helix-editor/helix)
- [neovim](https://github.com/neovim/neovim)

### 🖥️ Terminal

- [alacritty](https://github.com/alacritty/alacritty)

### ⚙️ Utilities

- [hammerspoon](https://www.hammerspoon.org)
- [mise](https://github.com/jdx/mise)
- [tldr](https://github.com/tldr-pages/tldr)
- [zoxide](https://github.com/ajeetdsouza/zoxide)

### 🕸️ Web Browsing

- [firefox](https://www.mozilla.org/en-US/firefox/new/)
  - [facebook container](https://addons.mozilla.org/en-US/firefox/addon/facebook-container/)
  - [noscript](https://addons.mozilla.org/en-US/firefox/addon/noscript/)
  - [privacy badger](https://addons.mozilla.org/en-US/firefox/addon/privacy-badger17/)
  - [sponsor block](https://addons.mozilla.org/en-US/firefox/addon/sponsorblock/)
  - [tosdr](https://addons.mozilla.org/en-US/firefox/addon/terms-of-service-didnt-read/)
  - [ublock origin](https://addons.mozilla.org/en-US/firefox/addon/ublock-origin/)
  - [video downloadhelper](https://addons.mozilla.org/en-US/firefox/addon/video-downloadhelper/)

### 🪟 Window manager

- [aerospace](https://github.com/nikitabobko/AeroSpace)
- [hyprland](https://github.com/hyprwm/Hyprland)
- [i3wm](https://github.com/i3/i3)
