# omz-git-flow-next

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
[![git-flow-next](https://img.shields.io/badge/git--flow--next-2.1.0-blue)](https://git-flow.sh)
![zsh](https://img.shields.io/badge/shell-zsh-informational)

📖 **Documentation**: [English](README.md) | [简体中文](README.zh-CN.md)

An [Oh My Zsh](https://github.com/ohmyzsh/ohmyzsh) plugin for
[git-flow-next](https://git-flow.sh), the Go reimplementation of git-flow
maintained by the team at [Tower](https://www.git-tower.com). It adds `gfl*`
aliases for every branch type and action, keeps the shell completion in sync
with the installed binary, and can opt into git-flow-next's worktree
navigation.

## Table of contents

- [Requirements](#requirements)
- [Installation](#installation)
- [Aliases](#aliases)
- [Completion](#completion)
- [Configuration](#configuration)
- [Differences from the git-flow plugin](#differences-from-the-git-flow-plugin)
- [License](#license)

## Requirements

- [Oh My Zsh](https://github.com/ohmyzsh/ohmyzsh)
- [git-flow-next](https://git-flow.sh) 2.x — `brew install gittower/tap/git-flow-next`

Check the installation with `git flow version`, which should print something
like `2.1.0 (git-flow-next)`.

## Installation

### With the installer

```zsh
curl -fsSL https://raw.githubusercontent.com/persiliao/omz-git-flow-next/main/install.sh | sh
```

The installer clones the plugin into the custom plugins directory it resolves
from `~/.zshrc`, adds `git-flow-next` to the `plugins` array — after keeping a
timestamped backup of the file — and reports whether the git-flow-next binary
is available. Run it again to update the plugin, add `--uninstall` to take it
out again, and `--help` lists the remaining options (`--dir`, `--repo`, `--ref`,
`--no-zshrc`).

Already have a clone of the repository? Run the script from inside it and that
clone *is* the plugin: it is linked into the custom plugins directory instead of
being cloned a second time, so `git pull` in the clone is all an update needs.
Nothing is ever pulled, deleted or rewritten inside your own working tree, and a
clone you placed in the plugins directory yourself is used in place.

```zsh
git clone https://github.com/persiliao/omz-git-flow-next
cd omz-git-flow-next && ./install.sh
```

### By hand

Clone the repository into your Oh My Zsh custom plugins directory, under the
name of the plugin:

```zsh
git clone https://github.com/persiliao/omz-git-flow-next \
  "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/git-flow-next"
```

Then add it to the `plugins` array in `~/.zshrc` and restart the shell:

```zsh
plugins=(git git-flow-next)
```

Load this plugin *instead of* the bundled `git-flow` or `git-flow-avh` plugins,
not together with them: they provide the same `gfl*` aliases and the same
`git flow` completion, and git-flow-next conflicts with the original git-flow
formula in Homebrew because both install the same binary.

### Uninstall

```zsh
curl -fsSL https://raw.githubusercontent.com/persiliao/omz-git-flow-next/main/install.sh |
  sh -s -- --uninstall
```

That removes the plugin directory or the link to it, its entry in the `plugins`
array, and the completion cache; a clone of the repository you ran the script
from is kept. By hand: delete
`"${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/git-flow-next"`, drop
`git-flow-next` from the array, and delete
`$ZSH_CACHE_DIR/git-flow-next-completion.zsh`. The git-flow-next binary itself
is never installed or removed.

## Aliases

### General commands

| Alias    | Command                | Description                                     |
| -------- | ---------------------- | ----------------------------------------------- |
| `gfl`    | `git flow`             | Run any git-flow-next command                    |
| `gfli`   | `git flow init`        | Initialize git-flow in a repository              |
| `gflo`   | `git flow overview`    | Show the configured branches and active topics   |
| `gflc`   | `git flow config list` | Show the resolved git-flow configuration         |
| `gflv`   | `git flow version`     | Show the git-flow-next version                   |
| `gflfin` | `git flow finish`      | Finish the branch you are on, prefix optional    |
| `gflpub` | `git flow publish`     | Publish the branch you are on                    |
| `gflupd` | `git flow update`      | Update the branch you are on from its parent     |
| `gflreb` | `git flow rebase`      | Rebase the branch you are on onto its parent     |
| `gfldel` | `git flow delete`      | Delete the branch you are on                     |
| `gflren` | `git flow rename`      | Rename the branch you are on                     |
| `gflwt`  | `git flow worktree`    | Manage the worktrees of branches                 |

### Branch type commands

Every topic branch type gets the same set of aliases: `gfl<type><action>`, so
`gflfs` starts a feature and `gflhs` starts a hotfix.

| Action (`l`ist is also the bare alias) | feature `f` | bugfix `b` | hotfix `h` | release `r` | support `s` |
| -------------------------------------- | ----------- | ---------- | ---------- | ----------- | ----------- |
| list / help                            | `gflf`      | `gflb`     | `gflh`     | `gflr`      | `gfls`      |
| start                                  | `gflfs`     | `gflbs`    | `gflhs`    | `gflrs`     | `gflss`     |
| finish                                 | `gflff`     | `gflbf`    | `gflhf`    | `gflrf`     | `gflsf`     |
| publish                                | `gflfp`     | `gflbp`    | `gflhp`    | `gflrp`     | `gflsp`     |
| update                                 | `gflfu`     | `gflbu`    | `gflhu`    | `gflru`     | `gflsu`     |
| rebase (`update --rebase`)             | `gflfb`     | `gflbb`    | `gflhb`    | `gflrb`     | `gflsb`     |
| checkout                               | `gflfc`     | `gflbc`    | `gflhc`    | `gflrc`     | `gflsc`     |
| list                                   | `gflfl`     | `gflbl`    | `gflhl`    | `gflrl`     | `gflsl`     |
| delete                                 | `gflfd`     | `gflbd`    | `gflhd`    | `gflrd`     | `gflsd`     |
| rename                                 | `gflfn`     | `gflbn`    | `gflhn`    | `gflrn`     | `gflsn`     |
| track (a remote branch)                | `gflft`     | `gflbt`    | `gflht`    | `gflrt`     | `gflst`     |

`finish`, `publish`, `update`, `rebase`, `checkout` and `delete` take the branch
name optionally and fall back to the branch you are standing on, so `gflff`
finishes the current feature branch and `gflff checkout-me` finishes a named
one, while `start` and `track` require a name and `rename` also takes the new
one. Extra flags are passed through unchanged:

```zsh
gflfs user-profiles          # git flow feature start user-profiles
gflrs 1.4.0                  # git flow release start 1.4.0
gflff --squash --no-push     # git flow feature finish --squash --no-push
gflhf                        # git flow hotfix finish   (current hotfix)
```

### Finishing a branch that has no prefix

git-flow-next takes the topic type from the prefix of the branch you are
standing on, and stops on a branch that carries none — `codex/i18n-pass` is not
a topic branch:

```
Error: current branch 'codex/i18n-pass' is not a valid topic branch
       (use explicit command, e.g., git flow feature finish)
```

Naming the branch is all git-flow-next needs to finish it after all, so `gflfin`
and the `gfl<type>f` aliases name it instead of stopping there: the name gets
the branch past the prefix check, and one question is left — git-flow-next's own
confirmation.

```
Warning: Branch 'codex/i18n-pass' is not a standard feature branch (missing prefix 'feature/').
Finishing this branch will:
1. Merge it into 'develop' using the merge strategy
3. Delete the branch after successful merge
Do you want to continue? [y/N]:
```

The plugin asks nothing on top of that confirmation, and nothing runs on no. The
fallback only kicks in where it belongs: on an ordinary branch of a repository
git-flow is set up in, never on the trunk or `develop`, never on a branch that
already has a prefix, and never without a terminal in front of the command — a
script or an agent gets git-flow-next's own error, exactly as before. Commands
other than `finish` need the prefix to work at all, so `gflpub`, `gflupd` and
the rest keep failing.

The `…f` aliases expand to the plugin's `_git-flow-next-finish`, which is what
`which gflfin` prints, while typing `git flow finish` yourself still goes
straight to git-flow-next.

## Completion

git-flow-next generates its own zsh completion, and the plugin keeps a cached
copy of it so no process has to be spawned per prompt:

- the cache lives in `$ZSH_CACHE_DIR/git-flow-next-completion.zsh` and is
  regenerated whenever `git flow version` reports a new version;
- `git-flow …` completes through the `compdef` entry of the generated script;
- `git flow …` completes through a bridge. The generated script installs
  `_git-flow`, which zsh's `_git` is meant to pick up for any `git <subcommand>`
  — a step zsh 5.9 dropped, which leaves `git flow <TAB>` without a single
  suggestion — so the plugin wraps the `git` completion, forwards `git flow …`
  to `_git-flow`, and hands every other subcommand straight back to `_git`. The
  wrapper is skipped when `_git` is not what completes `git` in your shell, and
  you can drop it again with `compdef _git git`;
- subcommands, flags and their descriptions are all read from the binary, so a
  newer git-flow-next completes its own new commands without a plugin update.

Delete the cache file by hand if completion ever looks stale.

Aliases complete as what they expand to, so `gflpub --<TAB>` offers the flags of
`git flow publish`. The finish aliases expand to a plugin function instead,
which is why the plugin registers a completer for it: the line is rewritten to
the `git flow [<type>] finish …` the alias stands for, so `gflff --<TAB>` and
`gflfin --<TAB>` list exactly what the command lists.

What is missing everywhere is positional values — git-flow-next completes flags
only, so a `<TAB>` where a branch name belongs falls back to file names, on
`git flow feature finish <TAB>` just as much as on `gflff <TAB>`.

## Configuration

All settings are `zstyle` values under `:omz:plugins:git-flow-next`, and belong
in `~/.zshrc` *before* the `source $ZSH/oh-my-zsh.sh` line.

| Setting      | Default | Description                                                                                                                                                        |
| ------------ | ------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| `shell-init` | `no`    | Evaluate `git flow shell-init zsh`, which wraps `git` so that `git flow worktree add` and `<type> start --worktree` also change the directory of the current shell |
| `aliases`    | `yes`   | Oh My Zsh standard switch: set to `no` to source the plugin without defining any alias; the `_git-flow-next-*` helper functions stay defined and do nothing on their own |

```zsh
# Follow the branch into its new worktree
zstyle ':omz:plugins:git-flow-next' shell-init yes
```

The wrapper is opt-in on purpose: it redefines `git` as a function, which is a
bigger change to the shell than an alias.

## Differences from the git-flow plugin

- **No `…c` current-branch aliases.** `gflffc` and friends existed because
  git-flow needed a branch name; git-flow-next reads it from the branch you are
  standing on, so `gflff` already covers both cases. The type-agnostic
  `gflfin` / `gflpub` / `gflupd` shorthands go one step further and detect the
  branch *type* from its prefix too.
- **`gcd` / `gcm` are not redefined.** Checking out `develop` or the trunk is
  the job of the `git` plugin, which resolves both from the branch names that
  actually exist in the repository.
- **More branch types, more actions.** `bugfix` and `support` are first-class
  types in git-flow-next, and `update`, `rebase`, `checkout`, `rename`,
  `delete`, `track`, `overview` and `worktree` have no git-flow equivalent.
- **Configuration keys changed.** git-flow-next stores
  `gitflow.branch.<type>.*` instead of `gitflow.prefix.*` / `gitflow.branch.develop`,
  so the old plugin cannot read anything from a repository you initialized with
  the new one. Run `git flow init` once per repository — it imports existing
  git-flow-avh settings — and `git flow config status` to compare them with a
  shared `.gitflow` file.

## License

This plugin is released under the [MIT License](LICENSE). git-flow-next itself
is licensed under the BSD 2-Clause License.
