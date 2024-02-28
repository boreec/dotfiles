# include aliases
source ~/.zsh_aliases

export PATH="$HOME/scripts:$PATH"

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
