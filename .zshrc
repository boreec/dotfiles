# include aliases
source ~/.zsh_aliases

export PATH="$HOME/scripts:$PATH"

# Check if starship is installed
if command -v starship &> /dev/null; then
    eval "$(starship init zsh)"
fi

# Check if zoxide is installed
if command -v zoxide &> /dev/null; then
    eval "$(zoxide init zsh)"
fi
