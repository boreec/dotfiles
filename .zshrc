# NVM
export NVM_DIR=~/.nvm
source $(brew --prefix nvm)/nvm.sh


# load vcs info
# Load version control information
autoload -Uz vcs_info
precmd() { vcs_info }

setopt prompt_subst
autoload -Uz vcs_info
zstyle ':vcs_info:*' actionformats \
    '%F{5}(%f%s%F{5})%F{3}-%F{5}[%F{2}%b%F{3}|%F{1}%a%F{5}]%f '
zstyle ':vcs_info:*' formats       \
    '%F{5}(%f%s%F{5})%F{3}-%F{5}[%F{2}%b%F{5}]%f '
zstyle ':vcs_info:(sv[nk]|bzr):*' branchformat '%b%F{1}:%F{3}%r'

zstyle ':vcs_info:*' enable git cvs svn

# or use pre_cmd, see man zshcontrib
vcs_info_wrapper() {
  vcs_info
  if [ -n "$vcs_info_msg_0_" ]; then
    echo "%{$fg[grey]%}${vcs_info_msg_0_}%{$reset_color%}$del"
  fi
}
RPROMPT="%B%F{219}$(vcs_info_wrapper)%f%b"

# prompt
HOST="M1Ventura"
PROMPT="%B%F{229}%n%f%b%B%F{229}@%f%b%B%F{229}%m%f%b %B%F{159}%~%f%b "

# add colors when using ls command
export LS_COLORS="$(vivid generate molokai)"
alias ls="gls --color"

# delete git branches whose name start with on of the following prefixes:
alias git-clean-branches='git branch -d \
  $(git branch -l "chore/*") \
  $(git branch -l "docs/*") \
  $(git branch -l "feat/*") \
  $(git branch -l "feature/*") \
  $(git branch -l "fix/*") \
  $(git branch -l "hotfix/*") \
  2>/dev/null || echo "no branches to clean"'

# psql
export PATH="/opt/homebrew/opt/postgresql@15/bin:$PATH"


autoload -Uz compinit && compinit

eval "$(starship init zsh)"
