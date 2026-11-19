#!/bin/sh
#
# Installer for the git-flow-next Oh My Zsh plugin.
#
#   curl -fsSL https://raw.githubusercontent.com/persiliao/omz-git-flow-next/main/install.sh | sh
#
# It clones the plugin into the Oh My Zsh custom plugins directory, enables it
# in the plugins array of ~/.zshrc, and reports whether the git-flow-next
# binary itself is available. --uninstall does the reverse and never touches
# the git-flow-next binary.
#
# @author Persi.Liao <xiangchu.liao@gmail.com>

set -eu

PLUGIN=git-flow-next
REPO=https://github.com/persiliao/omz-git-flow-next
REF=
DIR=
MODE=install
ZSHRC=${ZSHRC:-$HOME/.zshrc}
EDIT_ZSHRC=yes

log() { printf '==> %s\n' "$*"; }
warn() { printf 'WARNING: %s\n' "$*" >&2; }
die() { printf 'ERROR: %s\n' "$*" >&2; exit 1; }

usage() {
  cat <<USAGE
Usage: install.sh [OPTION]

Install the $PLUGIN plugin for Oh My Zsh, or remove it again with --uninstall.

Options:
  -u, --uninstall   Remove the plugin directory and disable it in ~/.zshrc
  -d, --dir PATH    Custom plugins directory, or the plugin directory itself
                    (default: \$ZSH_CUSTOM, then \$ZSH/custom, ~/.oh-my-zsh/custom)
      --repo URL    Clone from URL instead of $REPO
      --ref REF     Check out REF (branch or tag) instead of the default branch
      --no-zshrc    Only manage the files, leave ~/.zshrc alone
  -h, --help        Show this help
USAGE
}

while [ $# -gt 0 ]; do
  case $1 in
    -u | --uninstall) MODE=uninstall ;;
    -d | --dir)
      [ $# -ge 2 ] && [ -n "$2" ] || die "--dir needs a path"
      DIR=$2
      shift
      ;;
    --repo)
      [ $# -ge 2 ] && [ -n "$2" ] || die "--repo needs a URL"
      REPO=$2
      shift
      ;;
    --ref)
      [ $# -ge 2 ] && [ -n "$2" ] || die "--ref needs a name"
      REF=$2
      shift
      ;;
    --no-zshrc) EDIT_ZSHRC=no ;;
    -h | --help)
      usage
      exit 0
      ;;
    *)
      usage >&2
      die "unknown option: $1"
      ;;
  esac
  shift
done

# Read the last assignment of a variable out of ~/.zshrc and expand a leading
# ~ or $HOME, so ZSH and ZSH_CUSTOM work even though only ZSH is exported.
zshrc_var() {
  [ -f "$ZSHRC" ] || return 0
  val=$(sed -n "s/^[[:space:]]*\(export[[:space:]][[:space:]]*\)*$1=//p" "$ZSHRC" | tail -n 1)
  val=$(printf '%s' "$val" | sed -e 's/[[:space:]]*#.*$//' -e 's/[[:space:]]*$//' \
    -e 's/^["'"'"']*//' -e 's/["'"'"']*$//')
  case $val in
    '~') val=$HOME ;;
    '~/'*) val="$HOME/${val#\~/}" ;;
    '$HOME'/*) val="$HOME/${val#\$HOME/}" ;;
    '${HOME}'/*) val="$HOME/${val#\${HOME}/}" ;;
  esac
  printf '%s\n' "$val"
}

# Where the plugin lives: <custom>/plugins/<name>. An explicit --dir wins,
# otherwise the values of the running shell are used and ~/.zshrc fills in the
# gaps.
if [ -n "$DIR" ]; then
  case $DIR in
    */"$PLUGIN") TARGET=$DIR ;;
    *) TARGET="${DIR%/}/plugins/$PLUGIN" ;;
  esac
else
  CUSTOM_DIR=${ZSH_CUSTOM:-}
  [ -n "$CUSTOM_DIR" ] || CUSTOM_DIR=$(zshrc_var ZSH_CUSTOM)

  ZSH_DIR=${ZSH:-}
  [ -n "$ZSH_DIR" ] || ZSH_DIR=$(zshrc_var ZSH)
  [ -n "$ZSH_DIR" ] || ZSH_DIR="$HOME/.oh-my-zsh"

  case $CUSTOM_DIR in
    '$ZSH'/*) CUSTOM_DIR="$ZSH_DIR/${CUSTOM_DIR#\$ZSH/}" ;;
    '${ZSH}'/*) CUSTOM_DIR="$ZSH_DIR/${CUSTOM_DIR#\${ZSH}/}" ;;
  esac
  [ -n "$CUSTOM_DIR" ] || CUSTOM_DIR="$ZSH_DIR/custom"

  TARGET="$CUSTOM_DIR/plugins/$PLUGIN"
fi

# Add or remove one entry of the plugins array in ~/.zshrc. A multi-line array
# is left as it is: guessing where its closing parenthesis belongs is worse
# than asking for the one line that has to be added.
zshrc_patch() {
  mode=$1

  if [ ! -f "$ZSHRC" ]; then
    warn "$ZSHRC not found, add '$PLUGIN' to the plugins array yourself"
    return 0
  fi

  tmp=$(mktemp "$ZSHRC.XXXXXX")
  if ! awk -v plugin="$PLUGIN" -v mode="$mode" '
    function blank(c) { return (c == " " || c == "\t") }
    !done && /^[[:blank:]]*plugins=[(]/ {
      done = 1
      open = index($0, "(")
      pre = substr($0, 1, open)
      rest = substr($0, open + 1)
      pos = 0
      for (i = length(rest); i > 0; i--) {
        if (substr(rest, i, 1) == ")") { pos = i; break }
      }
      if ($0 !~ /[)]/ || pos == 0) { print; exit 3 }   # multi-line array
      body = substr(rest, 1, pos - 1)
      tail = substr(rest, pos)
      lead = blank(substr(body, 1, 1)) ? " " : ""
      trail = blank(substr(body, length(body), 1)) ? " " : ""
      sub(/^[[:blank:]]+/, "", body)
      sub(/[[:blank:]]+$/, "", body)
      n = split(body, items, /[[:blank:]]+/)
      has = 0
      for (i = 1; i <= n; i++) { if (items[i] == plugin) has = 1 }
      if (mode == "enable" && !has) {
        print pre lead body (body == "" ? "" : " ") plugin trail tail
      } else if (mode == "disable" && has) {
        kept = ""
        for (i = 1; i <= n; i++) {
          if (items[i] != "" && items[i] != plugin) kept = kept items[i] " "
        }
        sub(/ $/, "", kept)
        print pre lead kept trail tail
      } else {
        print
      }
      next
    }
    { print }
  ' "$ZSHRC" >"$tmp"; then
    rm -f -- "$tmp"
    warn "$ZSHRC: the plugins array spans several lines, add '$PLUGIN' to it by hand"
    return 0
  fi

  if cmp -s -- "$tmp" "$ZSHRC"; then
    rm -f -- "$tmp"
    return 0
  fi

  backup="$ZSHRC.bak.$(date +%Y%m%d%H%M%S)"
  cp -p -- "$ZSHRC" "$backup"
  cat -- "$tmp" >"$ZSHRC"
  rm -f -- "$tmp"
  log "Updated $ZSHRC (previous version kept in $backup)"
}

if [ "$MODE" = uninstall ]; then
  if [ -d "$TARGET" ]; then
    if [ -f "$TARGET/$PLUGIN.plugin.zsh" ] || [ -d "$TARGET/.git" ]; then
      log "Removing $TARGET"
      rm -rf -- "$TARGET"
    else
      warn "$TARGET does not look like this plugin, left it alone"
    fi
  else
    log "No plugin directory at $TARGET"
  fi

  if [ "$EDIT_ZSHRC" = yes ]; then
    zshrc_patch disable
  fi

  rm -f -- "${ZSH_CACHE_DIR:-${ZSH_DIR:-$HOME/.oh-my-zsh}/cache}/$PLUGIN-completion.zsh"
  rm -rf -- "${XDG_CACHE_HOME:-$HOME/.cache}/omz-git-flow-next"
  log "Done. The git-flow-next binary and any zstyle line were left untouched."
  exit 0
fi

if [ -z "$DIR" ] && [ ! -d "$TARGET" ] && [ ! -d "$CUSTOM_DIR" ]; then
  die "Oh My Zsh not found under $CUSTOM_DIR. Install it first, or pass --dir."
fi

if [ -d "$TARGET/.git" ]; then
  log "Updating $TARGET"
  if ! git -C "$TARGET" pull --ff-only >/dev/null 2>&1; then
    warn "could not update $TARGET, keeping the version you have"
  fi
elif [ -e "$TARGET" ]; then
  if [ -f "$TARGET/$PLUGIN.plugin.zsh" ]; then
    warn "$TARGET is not a git clone, keeping the files you have"
  else
    die "$TARGET exists and is not this plugin; remove it or pass --dir"
  fi
else
  log "Cloning $REPO into $TARGET"
  command mkdir -p -- "$(dirname "$TARGET")"
  if [ -n "$REF" ]; then
    git clone --depth 1 --branch "$REF" -- "$REPO" "$TARGET" >/dev/null 2>&1 ||
      die "could not clone $REPO ($REF) into $TARGET"
  else
    git clone --depth 1 -- "$REPO" "$TARGET" >/dev/null 2>&1 ||
      die "could not clone $REPO into $TARGET"
  fi
fi

[ -f "$TARGET/$PLUGIN.plugin.zsh" ] || die "$TARGET has no $PLUGIN.plugin.zsh"

if [ "$EDIT_ZSHRC" = yes ]; then
  zshrc_patch enable
  if grep -E '^[[:space:]]*plugins=[(]' "$ZSHRC" 2>/dev/null |
    grep -qE '(^|[[:space:]])git-flow(-avh)?([[:space:])]|$)'; then
    warn "git-flow / git-flow-avh is enabled too; drop it, it clashes with $PLUGIN"
  fi
fi

if command -v git-flow >/dev/null 2>&1; then
  log "git-flow $(command git-flow version 2>/dev/null | head -n 1)"
else
  warn "git-flow-next is not installed: brew install gittower/tap/git-flow-next"
fi

if [ "$EDIT_ZSHRC" = yes ]; then
  log "Done. Restart the shell, or run: . $ZSHRC"
else
  log "Done. Enable it yourself in $ZSHRC: plugins=(git $PLUGIN)"
fi
