# delete git branches whose name start with on of the following prefixes:
alias git-clean-branches='git branch -d \
  $(git branch -l "chore/*") \
  $(git branch -l "docs/*") \
  $(git branch -l "feat/*") \
  $(git branch -l "feature/*") \
  $(git branch -l "fix/*") \
  $(git branch -l "hotfix/*") \
  2>/dev/null || echo "no branches to clean"'


eval "$(starship init zsh)"
