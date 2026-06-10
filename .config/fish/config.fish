# Environment variables
set -U fish_greeting
set -gx EDITOR vim
set -gx GOPATH $HOME/go

# Secrets (API tokens, passwords) live in an untracked, gitignored file.
test -f ~/.config/fish/secrets.fish; and source ~/.config/fish/secrets.fish

# Paths
fish_add_path $GOPATH/bin
fish_add_path "$HOME/.local/bin"

direnv hook fish | source
mise activate fish | source
starship init fish | source
# zoxide rebinds `cd`, which confuses Claude Code's shell; skip it in that env.
if test "$CLAUDECODE" != 1
    zoxide init fish | source
    alias cd 'z'
end

alias ls        'lsd'
alias ll        'lsd -l'
alias ga        'git add'
alias gap       'git add -p'
alias gc        'git commit'
alias gcm       'git commit -m'
alias gd        'git diff'
alias gds       'git diff --staged'
alias gl        "git log --color --graph --pretty=format:'%Cred%h%Creset \
  -%C(yellow)%d%Creset %s %Cgreen(%cr) \
  %C(bold blue)<%an>%Creset' \
  --abbrev-commit"
alias gs        'git status'
alias gpl       'git pull'
alias gps       'git push'
alias git-clean-branches 'git branch -d \
  $(git branch -l "chore/*") \
  $(git branch -l "docs/*") \
  $(git branch -l "feat/*") \
  $(git branch -l "feature/*") \
  $(git branch -l "fix/*") \
  $(git branch -l "hotfix/*") \
  2>/dev/null || echo "no branches to clean"'
alias prc       'pre-commit'
alias tmux      'tmux -f ~/.config/tmux/tmux.conf'
alias n         'nvim'
alias claude    'claude --plugin-dir ~/myskills/plugins/myskills'
alias ollama_setup 'docker run -d --gpus=all -v ollama:/root/.ollama -p 11434:11434 --name ollama ollama/ollama'
alias ollama_docker_run 'docker exec -it ollama ollama run hf.co/SandLogicTechnologies/DeepSeek-Coder-V2-Lite-Instruct-GGUF:Q4_K_M'
