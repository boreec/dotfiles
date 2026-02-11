set -U fish_greeting
set -gx EDITOR vim
set -gx GOPATH $HOME/go

fish_add_path $GOPATH/bin

if status is-interactive
    if not set -q TMUX
        exec tmux
    end
end

direnv hook fish | source
mise activate fish | source
starship init fish | source
zoxide init fish | source

alias cd        'z'
alias dofus     '~/Ankama\ Launcher-Setup-x86_64.AppImage'
alias ga        'git add'
alias gap       'git add -p'
alias gc        'git commit'
alias gcm       'git commit -m'
alias gd        'git diff'
alias gds       'git diff --staged'
alias gs        'git status'
alias gpl       'git pull'
alias gps       'git push'
alias gcleanbr  'git branch -d \
  (git branch -l "chore/*") \
  (git branch -l "docs/*") \
  (git branch -l "feat/*") \
  (git branch -l "feature/*") \
  (git branch -l "fix/*") \
  (git branch -l "hotfix/*") \
  2>/dev/null || echo "no branches to clean"'
alias ls        'ls --color=auto'
alias ll        'ls --color=auto -l'
alias n         'nvim'
alias prc       'pre-commit'
alias tmux      'tmux -f ~/.config/tmux/tmux.conf'
