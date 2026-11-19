# omz-git-flow-next

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
[![git-flow-next](https://img.shields.io/badge/git--flow--next-2.1.0-blue)](https://git-flow.sh)
![zsh](https://img.shields.io/badge/shell-zsh-informational)

📖 **文档**：[English](README.md) | [简体中文](README.zh-CN.md)

面向 [git-flow-next](https://git-flow.sh) 的 [Oh My Zsh](https://github.com/ohmyzsh/ohmyzsh) 插件。
git-flow-next 是 Tower 团队用 Go 重写的 git-flow。本插件为所有分支类型和子命令提供 `gfl*`
别名，让补全始终跟随已安装的二进制，并可选开启 git-flow-next 的 worktree 目录跟随。

## 目录

- [环境要求](#环境要求)
- [安装](#安装)
- [别名](#别名)
- [补全](#补全)
- [配置](#配置)
- [与 git-flow 插件的差异](#与-git-flow-插件的差异)
- [许可证](#许可证)

## 环境要求

- [Oh My Zsh](https://github.com/ohmyzsh/ohmyzsh)
- [git-flow-next](https://git-flow.sh) 2.x —— `brew install gittower/tap/git-flow-next`

用 `git flow version` 确认安装结果，正常输出类似 `2.1.0 (git-flow-next)`。

## 安装

### 使用安装脚本

```zsh
curl -fsSL https://raw.githubusercontent.com/persiliao/omz-git-flow-next/main/install.sh | sh
```

脚本会按 `~/.zshrc` 解析出的自定义插件目录克隆插件，在 `plugins` 数组中加入
`git-flow-next`（修改前先备份一份带时间戳的 `~/.zshrc`），并提示 git-flow-next
可执行文件是否已安装。再次运行即更新插件，加 `--uninstall` 卸载，`--help`
列出其余选项（`--dir`、`--repo`、`--ref`、`--no-zshrc`）。

### 手动安装

把仓库克隆到 Oh My Zsh 的自定义插件目录，并以插件名作为目录名：

```zsh
git clone https://github.com/persiliao/omz-git-flow-next \
  "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/git-flow-next"
```

然后在 `~/.zshrc` 的 `plugins` 数组中启用，并重开终端：

```zsh
plugins=(git git-flow-next)
```

本插件应当**替代** Oh My Zsh 自带的 `git-flow` 或 `git-flow-avh` 插件，而不是与它们同时加载：
它们提供同名的 `gfl*` 别名和同一份 `git flow` 补全；在 Homebrew 中 git-flow-next 也与原版
git-flow 冲突，因为两者安装同一个可执行文件。

### 卸载

```zsh
curl -fsSL https://raw.githubusercontent.com/persiliao/omz-git-flow-next/main/install.sh |
  sh -s -- --uninstall
```

它会删除插件目录、`plugins` 数组中的对应项以及补全缓存。手动卸载：删除
`"${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/git-flow-next"`，从数组中移除
`git-flow-next`，再删除 `$ZSH_CACHE_DIR/git-flow-next-completion.zsh`。
git-flow-next 可执行文件不会被安装，也不会被删除。

## 别名

### 通用命令

| 别名     | 命令                   | 说明                             |
| -------- | ---------------------- | -------------------------------- |
| `gfl`    | `git flow`             | 执行任意 git-flow-next 命令      |
| `gfli`   | `git flow init`        | 在仓库中初始化 git-flow          |
| `gflo`   | `git flow overview`    | 查看分支配置与进行中的主题分支   |
| `gflc`   | `git flow config list` | 查看解析后的 git-flow 配置       |
| `gflv`   | `git flow version`     | 查看 git-flow-next 版本          |
| `gflfin` | `git flow finish`      | 完结当前分支，类型自动识别       |
| `gflpub` | `git flow publish`     | 推送（发布）当前分支             |
| `gflupd` | `git flow update`      | 用父分支更新当前分支             |
| `gflreb` | `git flow rebase`      | 把当前分支 rebase 到父分支       |
| `gfldel` | `git flow delete`      | 删除当前分支                     |
| `gflren` | `git flow rename`      | 重命名当前分支                   |
| `gflwt`  | `git flow worktree`    | 管理分支的 worktree              |

### 分支类型命令

每种主题分支类型都拥有同一组别名，规则是 `gfl<类型><动作>`：`gflfs` 新建 feature，`gflhs` 新建 hotfix。

| 动作（列表也可用裸别名）      | feature `f` | bugfix `b` | hotfix `h` | release `r` | support `s` |
| ----------------------------- | ----------- | ---------- | ---------- | ----------- | ----------- |
| 列表 / 帮助                   | `gflf`      | `gflb`     | `gflh`     | `gflr`      | `gfls`      |
| start 新建                    | `gflfs`     | `gflbs`    | `gflhs`    | `gflrs`     | `gflss`     |
| finish 完结                   | `gflff`     | `gflbf`    | `gflhf`    | `gflrf`     | `gflsf`     |
| publish 发布                  | `gflfp`     | `gflbp`    | `gflhp`    | `gflrp`     | `gflsp`     |
| update 更新                   | `gflfu`     | `gflbu`    | `gflhu`    | `gflru`     | `gflsu`     |
| rebase（`update --rebase`）   | `gflfb`     | `gflbb`    | `gflhb`    | `gflrb`     | `gflsb`     |
| checkout 切换                 | `gflfc`     | `gflbc`    | `gflhc`    | `gflrc`     | `gflsc`     |
| list 列表                     | `gflfl`     | `gflbl`    | `gflhl`    | `gflrl`     | `gflsl`     |
| delete 删除                   | `gflfd`     | `gflbd`    | `gflhd`    | `gflrd`     | `gflsd`     |
| rename 重命名                 | `gflfn`     | `gflbn`    | `gflhn`    | `gflrn`     | `gflsn`     |
| track 跟踪远端分支            | `gflft`     | `gflbt`    | `gflht`    | `gflrt`     | `gflst`     |

`finish`、`publish`、`update`、`rebase`、`checkout`、`delete` 的分支名可以省略，默认作用于当前所在分支：
`gflff` 完结当前 feature，`gflff checkout-me` 完结指定 feature；`start` 与 `track` 必须给出分支名，
`rename` 还需给出新名字。附加参数原样透传：

```zsh
gflfs user-profiles          # git flow feature start user-profiles
gflrs 1.4.0                  # git flow release start 1.4.0
gflff --squash --no-push     # git flow feature finish --squash --no-push
gflhf                        # git flow hotfix finish   （当前 hotfix）
```

## 补全

git-flow-next 自带 zsh 补全脚本生成器，插件会缓存一份，避免每次补全都要启动进程：

- 缓存路径为 `$ZSH_CACHE_DIR/git-flow-next-completion.zsh`，当 `git flow version` 报告新版本时自动重新生成；
- `git-flow …` 由生成脚本里的 `compdef` 注册直接补全；
- `git flow …` 由插件的桥接函数补全。生成脚本注册的是 `_git-flow`，本应由 zsh 的 `_git`
  在补全 `git <子命令>` 时自动接管——但 zsh 5.9 重写后丢掉了这一步，导致 `git flow <TAB>` 一个候选都不给——
  因此插件会包装 `git` 的补全：只把 `git flow …` 转给 `_git-flow`，其余子命令原封不动交还 `_git`。
  若你 shell 里的 `git` 补全不是 `_git`，插件不会插手；也可以手动执行 `compdef _git git` 撤销这层包装；
- 子命令、参数与分支名都由二进制实时提供，升级 git-flow-next 后无需更新插件即可获得新命令的补全。

如果补全看起来过期，手动删除该缓存文件即可。别名只是简写而非补全：`gflff <TAB>` 取决于 zsh 的别名展开，
而 `git flow feature finish <TAB>` 一定能抵达 git-flow-next。

## 配置

所有开关都是 `:omz:plugins:git-flow-next` 下的 `zstyle` 配置，需写在 `~/.zshrc` 中
`source $ZSH/oh-my-zsh.sh` 之前。

| 配置项       | 默认值 | 说明                                                                                                             |
| ------------ | ------ | ---------------------------------------------------------------------------------------------------------------- |
| `shell-init` | `no`   | 执行 `git flow shell-init zsh`，把 `git` 包装成函数，使 `git flow worktree add` 与 `<type> start --worktree` 同时切换当前 shell 所在目录 |
| `aliases`    | `yes`  | Oh My Zsh 通用开关：设为 `no` 时加载插件但不定义任何别名                                                          |

```zsh
# 新建 worktree 后自动进入该目录
zstyle ':omz:plugins:git-flow-next' shell-init yes
```

之所以默认关闭：它会把 `git` 重新定义为函数，对 shell 的影响比一个别名大得多。

## 与 git-flow 插件的差异

- **没有 `…c` 结尾的“当前分支”别名。** `gflffc` 之类的别名存在，是因为原版 git-flow 必须传入分支名；
  git-flow-next 会直接读取当前分支，所以 `gflff` 已经覆盖两种用法。类型无关的
  `gflfin` / `gflpub` / `gflupd` 更进一步，连分支类型也按前缀自动识别。
- **不再重复定义 `gcd` / `gcm`。** 切换到 `develop` 或主干分支是 `git` 插件的职责，它会按仓库中真实存在的分支名解析。
- **分支类型与动作更多。** `bugfix` 与 `support` 在 git-flow-next 中是一等公民；
  `update`、`rebase`、`checkout`、`rename`、`delete`、`track`、`overview`、`worktree` 在原版 git-flow 中没有对应命令。
- **配置项键名变了。** git-flow-next 使用 `gitflow.branch.<type>.*`，不再使用
  `gitflow.prefix.*` / `gitflow.branch.develop`，因此旧插件读不到新初始化仓库的任何配置。
  每个仓库执行一次 `git flow init` 即可——它会导入已有的 git-flow-avh 配置；
  再用 `git flow config status` 检查本地配置与共享的 `.gitflow` 文件是否一致。

## 许可证

本插件基于 [MIT License](LICENSE) 发布；git-flow-next 本身基于 BSD 2-Clause 许可证。
