# git-flow-next plugin for Oh My Zsh
#
# Aliases and shell completion for git-flow-next (https://git-flow.sh), the Go
# reimplementation of git-flow maintained by the team at Tower.
#
# Install it with the installer shipped next to this file:
#
#   ./install.sh
#
# or clone it into the custom plugins directory and add `git-flow-next` to the
# plugins array in ~/.zshrc:
#
#   git clone https://github.com/persiliao/omz-git-flow-next \
#     "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/git-flow-next"
#
# Load it instead of the `git-flow` / `git-flow-avh` plugins, not together with
# them: they provide the same `gfl*` aliases and the same `git flow` completion.
#
# @author Persi.Liao <xiangchu.liao@gmail.com>

# ---------------------------------------------------------------------------
# Aliases
# ---------------------------------------------------------------------------

alias gfl='git flow'
alias gfli='git flow init'
alias gflo='git flow overview'
alias gflc='git flow config list'
alias gflv='git flow version'

# Shorthands for the branch you are standing on. git-flow-next derives the
# topic type from the branch prefix, so nothing has to be spelled out.
alias gflfin='git flow finish'
alias gflpub='git flow publish'
alias gflupd='git flow update'
alias gflreb='git flow rebase'
alias gfldel='git flow delete'
alias gflren='git flow rename'
alias gflwt='git flow worktree'

# Per branch type: gfl<type><action>, so `gflfs` starts a feature and `gflhs`
# starts a hotfix. Unlike git-flow, `finish`, `publish`, `update`, `checkout`
# and `delete` all default to the branch you are standing on, which is why the
# `…c` current-branch aliases of the git-flow plugin are not repeated here.
#
#   type:   b = bugfix   f = feature   h = hotfix   r = release   s = support
#   action: c checkout   d delete      f finish     l list        n rename
#           p publish    s start       t track      u update      b rebase
for _gfn_type in 'b:bugfix' 'f:feature' 'h:hotfix' 'r:release' 's:support'; do
  alias "gfl${_gfn_type%%:*}"="git flow ${_gfn_type#*:}"

  for _gfn_action in \
    'c:checkout' 'd:delete' 'f:finish' 'l:list' 'n:rename' \
    'p:publish' 's:start' 't:track' 'u:update'; do
    alias "gfl${_gfn_type%%:*}${_gfn_action%%:*}"="git flow ${_gfn_type#*:} ${_gfn_action#*:}"
  done

  # Rebasing a topic branch onto its parent is update with the strategy forced.
  alias "gfl${_gfn_type%%:*}b"="git flow ${_gfn_type#*:} update --rebase"
done
unset _gfn_type _gfn_action

# ---------------------------------------------------------------------------
# Worktree navigation
# ---------------------------------------------------------------------------
#
# `git flow worktree add` and `<type> start --worktree` hand the new directory
# back to the calling shell; git-flow-next's shell integration turns that hint
# into an actual cd. It defines a `git` wrapper function, so it stays opt-in:
#
#   zstyle ':omz:plugins:git-flow-next' shell-init yes
if zstyle -t ':omz:plugins:git-flow-next' shell-init \
  && command -v git-flow >/dev/null 2>&1; then
  eval "$(command git-flow shell-init zsh)"
fi

# ---------------------------------------------------------------------------
# Completion
# ---------------------------------------------------------------------------
#
# The completion script comes from git-flow-next itself, which keeps it in step
# with the installed version. Generating it spawns the binary, so the result is
# cached and refreshed whenever the version changes.
if (( $+functions[compdef] )) && command -v git-flow >/dev/null 2>&1; then
  _gfn_cache="${ZSH_CACHE_DIR:-${XDG_CACHE_HOME:-$HOME/.cache}/omz-git-flow-next}/git-flow-next-completion.zsh"
  _gfn_version="$(command git-flow version 2>/dev/null | head -n 1)"

  # The version is kept on the last line of the file to mark the cache fresh.
  if [[ ! -f "$_gfn_cache" || "$(tail -n 1 -- "$_gfn_cache")" != "# $_gfn_version" ]]; then
    command mkdir -p -- "${_gfn_cache:h}"
    { command git-flow completion zsh; printf '# %s\n' "$_gfn_version"; } >|"$_gfn_cache"
  fi

  source "$_gfn_cache"

  # zsh's `_git` is supposed to hand `git flow …` over to `_git-flow`, but its
  # 5.9 rewrite lost that step, so bridge it here. Everything that is not
  # `flow` goes straight back to the handler being wrapped, and a `git`
  # completion owned by someone else is left alone.
  if (( $+functions[_git-flow] )) && [[ ${_comps[git]} == _git ]]; then
    _git-flow-bridge() {
      if [[ $words[1] == git && $words[2] == flow ]]; then
        local -a _gfn_words
        local _gfn_current=$CURRENT _gfn_status=0
        _gfn_words=("$words[@]")

        # Hand the arguments over as if git-flow had been called by name.
        words=("${words[@]:1}")
        (( CURRENT > 1 )) && (( CURRENT-- ))
        _git-flow
        _gfn_status=$?

        words=("${_gfn_words[@]}")
        CURRENT=$_gfn_current
        return $_gfn_status
      fi

      _git "$@"
    }
    compdef _git-flow-bridge git
  fi

  unset _gfn_cache _gfn_version
fi
