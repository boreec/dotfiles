USE_LOCAL_SEARXNG=1

export PATH="$HOME/scripts:$PATH"

if [ "$USE_LOCAL_SEARXNG" -eq 1 ]; then
    launch-server-searxng.sh
fi

# enable autocompletion
autoload -U compinit; compinit

if command -v starship &> /dev/null; then
    eval "$(starship init zsh)"
else
    echo "starship not installed, eval skipped"
fi

if command -v zoxide &> /dev/null; then
    eval "$(zoxide init zsh)"
else
    echo "zoxide not installed, eval skipped"
fi

# include aliases
source ~/.zsh_aliases
