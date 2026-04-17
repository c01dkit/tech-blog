# tmux学习笔记

tmux（terminal multiplexer，终端复用器）是服务器运维和日常开发中非常顺手的工具。它的核心价值概括起来有三点：

* **会话保活**。ssh连上远程服务器，一旦网络抖动或者本地终端关闭，所有前台进程就跟着被SIGHUP了。把命令放在tmux里运行，ssh断了只是detach而已，进程继续在服务器上跑，下次登录再`tmux attach`回来。
* **一屏多窗**。把一个物理终端窗口分成多个pane，一边看日志一边敲命令一边跑htop，不用频繁切alt+tab。
* **多终端共享同一会话**。在公司电脑attach一个session，回家在笔记本上再attach，两边能看到同样的屏幕，适合结对调试或者跨设备继续工作。

本文按「概念→会话→窗口→窗格→复制模式→配置→插件」的顺序展开，所有快捷键都以tmux默认的前缀键 ++ctrl+b++ 为基础。后面会讲到怎么把前缀键改成更顺手的 ++ctrl+a++。

## 安装

大多数发行版仓库里都自带：

```bash
# Debian / Ubuntu
sudo apt install tmux

# CentOS / RHEL
sudo yum install tmux

# macOS（Homebrew）
brew install tmux

# Arch
sudo pacman -S tmux
```

装完以后检查版本：`tmux -V`。建议用 3.0 以上的版本，很多现代配置项（比如`set -g mouse on`统一开关鼠标、`copy-mode-vi`的`send-keys -X`语法）在老版本里要么没有要么不一样。如果仓库里的版本太老，可以从源码编译，依赖是`libevent`和`ncurses`。

## 核心概念：session、window、pane

tmux里有三层嵌套关系，理清楚了后面的快捷键就不会乱：

* **Session（会话）**：一组窗口的集合，可以被命名。session是attach/detach的单位，也是「保活」的真正单元——只要tmux server没被杀，session里的进程就一直在跑。
* **Window（窗口）**：一个session里可以有多个window，概念上类似浏览器的标签页。每个window占满整个终端屏幕，同一时刻只会显示一个。
* **Pane（窗格）**：一个window内部又可以被切分成若干pane，每个pane是一个独立的shell进程。

它们的关系大致是：

```text
tmux server
 └── session "work"
      ├── window 0: editor
      │    ├── pane 0: vim
      │    └── pane 1: shell
      ├── window 1: logs
      │    ├── pane 0: tail -f a.log
      │    └── pane 1: tail -f b.log
      └── window 2: htop
```

tmux server在第一次运行`tmux`命令时自动被拉起来，之后所有的session都挂在这一个server下。想确认server是否在跑：`tmux ls`，没有server的时候会报`no server running on /tmp/tmux-1000/default`。

## 会话管理

启动一个匿名session：

```bash
tmux
```

启动时直接起名字（强烈推荐，否则session名就是0、1、2这种数字，多了根本分不清）：

```bash
tmux new -s work
```

离开session但保留后台运行（这是tmux最常用的操作）：按 ++ctrl+b++ 然后松开，再按 ++d++（detach）。也可以在任意shell里执行`tmux detach`。

列出所有活着的session：

```bash
tmux ls
# 或者在 tmux 内部：Ctrl+b s   会打开一个可选列表
```

重新挂回最近的session：

```bash
tmux a        # attach
tmux a -t work  # 指定名字 attach
```

`-d`参数很有用：在attach新的客户端时把原来连接那个session的其他客户端踢下线。适合「家里和公司两个终端attach同一个session结果屏幕大小互相掐架」的情形：

```bash
tmux a -dt work
```

干掉一个session：

```bash
tmux kill-session -t work
tmux kill-server          # 彻底把server也干掉，所有session一起走
```

重命名当前session：++ctrl+b++ ++$++，然后输入新名字回车。

!!! tip "保活的本质"
    tmux保活能力的关键在于它的子进程是由tmux server（一个daemon）fork出来的，而不是由你那个ssh shell fork出来的。ssh一断，只有你的ssh shell收到SIGHUP而死掉，server和它名下所有的shell都跟这个事件无关。所以只有`kill-server`、机器重启、或者系统OOM把tmux进程干掉，session才会真的丢。

## 窗口（window）管理

以下快捷键都省略了前缀 ++ctrl+b++。也就是说，`c`这一项实际的按法是先按 ++ctrl+b++、再按 ++c++：

| 按键 | 作用 |
|---|---|
| `c` | create，新建一个window |
| `,` | 重命名当前window |
| `&` | 关闭当前window（会弹确认） |
| `n` | next，切到下一个window |
| `p` | previous，切到上一个window |
| `0`~`9` | 直接切到编号为0~9的window |
| `l` | last，切回上一次停留的window |
| `w` | 打开window选择列表，可以用方向键选 |
| `f` | 按窗口标题搜索 |
| `.` | 改window的编号 |

window的编号默认从0开始，这个挺反直觉，习惯后可以在`.tmux.conf`里改成从1开始（见下面的配置章节）。

## 窗格（pane）管理

### 切分

| 按键 | 作用 |
|---|---|
| `%` | 把当前pane左右切开 |
| `"` | 把当前pane上下切开 |
| `x` | 关闭当前pane（会弹确认） |
| `!` | 把当前pane拎出来变成一个独立的window |

可以在配置里重映射成 `|` 和 `-`，视觉上符合直觉（见下面配置）。

### 切换焦点

| 按键 | 作用 |
|---|---|
| `o` | 顺次切到下一个pane |
| `;` | 切回上一次停留的pane |
| 方向键 | 按方位切pane（上下左右） |
| `q` | 显示每个pane的编号，按数字键跳过去 |
| `z` | zoom，把当前pane临时放大到全屏，再按一次复原 |

`q`+数字这个组合在pane比较多的时候非常省事，不用一格一格跳。

### 调整尺寸

按住前缀键之后用方向键也能调大小，但只动一格太慢。更顺手的方法是进入「按住模式」，在`.tmux.conf`里把方向键resize设成可重复：

```tmux
bind -r H resize-pane -L 5
bind -r J resize-pane -D 5
bind -r K resize-pane -U 5
bind -r L resize-pane -R 5
```

`-r`表示`repeat`，在默认500ms的重复时间内可以连着按`H`、`J`而不用重复前缀。

### 布局

++ctrl+b++ 按 `空格` 会在tmux预置的几种布局间循环切换：`even-horizontal`、`even-vertical`、`main-horizontal`、`main-vertical`、`tiled`。一屏多pane的时候用这个比手动调尺寸方便得多。

### 交换与移动

| 按键 | 作用 |
|---|---|
| `{` | 把当前pane往前挪一位 |
| `}` | 把当前pane往后挪一位 |
| `Ctrl+o` | 整个window里所有pane轮换一圈 |

跨window拉pane：`:join-pane -s <src>:<win>.<pane> -t <dst>:<win>`，在命令模式下运行。如果只是简单把当前pane合并到另一个window，`join-pane -t :<target-window>`更省事。

## 复制模式（copy mode）

tmux有自己的滚屏和复制机制。直接在tmux里滚鼠标滚轮（没开mouse的话）什么都不会发生，因为你没有进入复制模式。

进入复制模式：++ctrl+b++ ++\[++（左方括号）。进去之后屏幕右上角会出现`[N/M]`这样的位置提示，这时候就能用方向键、PgUp/PgDn滚动了。按 `q` 或者 ++esc++ 退出。

默认的键位是emacs风格的，用vi风格在配置里加上：

```tmux
setw -g mode-keys vi
```

vi模式下的操作：

| 按键 | 作用 |
|---|---|
| `h`/`j`/`k`/`l` | 左下上右移动 |
| `w`/`b` | 跳词 |
| `gg` / `G` | 跳到最顶 / 最底 |
| `/` / `?` | 向下 / 向上搜索 |
| `n` / `N` | 下一个 / 上一个匹配 |
| ++space++ | 开始选区 |
| ++enter++ | 把选区拷到tmux buffer |
| ++ctrl+b++ ++\]++ | 把最近一次的buffer粘贴回来 |

这个粘贴仍然在tmux内部。想和系统剪贴板互通需要借助外部工具，Linux下一般是`xclip`或者`xsel`，macOS下是`pbcopy`/`pbpaste`，WSL下是`clip.exe`。以Linux为例：

```tmux
bind -T copy-mode-vi y send-keys -X copy-pipe-and-cancel "xclip -selection clipboard -i"
```

这样按`y`复制时就会同时送到X11剪贴板，在浏览器里`Ctrl+V`粘贴即可。

## 命令模式

按 ++ctrl+b++ ++:++ 进入命令模式，状态栏会变成冒号提示符，就像vim的 ex 命令。所有在`.tmux.conf`里能写的指令在这里都能临时执行，调试配置的时候特别方便。

一些常用的命令：

```tmux
:new-window -n edit              新建window并命名
:rename-window logs              给当前window改名
:rename-session deploy           给当前session改名
:kill-pane                       关闭当前pane
:source-file ~/.tmux.conf        重载配置（非常常用）
:set -g mouse on                 临时开启鼠标支持
:swap-window -s 3 -t 0           把3号和0号window对调
:move-window -t 2                把当前window移到位置2
```

## 快捷键速查

把上面的东西整理成一张图，打印出来贴屏幕上（前缀键均为 ++ctrl+b++，省略）：

| 类别 | 按键 | 说明 |
|---|---|---|
| session | `d` | detach |
| session | `s` | 选择session |
| session | `$` | 重命名session |
| session | `(` / `)` | 上一/下一个session |
| window | `c` | 新建window |
| window | `,` | 重命名window |
| window | `&` | 关闭window |
| window | `n` / `p` | 下/上一个window |
| window | `0`~`9` | 跳到编号window |
| window | `w` | 选择window |
| window | `f` | 搜索window |
| pane | `%` / `"` | 左右/上下切分 |
| pane | 方向键 | 按方向切pane |
| pane | `o` / `;` | 下一个/上一次pane |
| pane | `q` | 显示编号 |
| pane | `x` | 关闭pane |
| pane | `z` | 放大/还原pane |
| pane | `{` / `}` | 前后挪动pane |
| pane | 空格 | 切换布局 |
| 其他 | `[` | 进入复制模式 |
| 其他 | `]` | 粘贴 |
| 其他 | `:` | 命令模式 |
| 其他 | `?` | 显示所有快捷键绑定 |
| 其他 | `t` | 在当前pane显示一个大时钟（闲着无聊可以看） |

按 `?` 显示所有绑定是一个很容易被忽略的自救技能：忘记某个键的时候不用Google。

## 配置文件 `.tmux.conf`

tmux启动时会读 `~/.tmux.conf`，修改后可以用 `tmux source ~/.tmux.conf` 或者在tmux里按 ++ctrl+b++ ++:++ 执行 `source-file ~/.tmux.conf` 立即生效，不需要重启server。

下面是一个比较通用的配置模板，把上面的注意事项都合并进来了：

```tmux
# -------- 基础行为 --------
# 可以前缀键改成 Ctrl+a，和 screen 一致
unbind C-b
set -g prefix C-a
bind C-a send-prefix        # 按两次 Ctrl+a 向内层应用传一个 Ctrl+a

# 窗口和面板编号从 1 开始
set -g base-index 1
setw -g pane-base-index 1

# 有 window 关闭时，自动重编号，让编号保持连续
set -g renumber-windows on

# 历史行数调大一点，方便向上翻
set -g history-limit 50000

# 降低 escape 延迟，vim 里切 normal 模式会感觉明显顺
set -sg escape-time 10

# 支持真彩色（前提是外层终端也支持）
set -g default-terminal "tmux-256color"
set -ga terminal-overrides ",xterm-256color:Tc"

# 鼠标：允许滚轮、点选 pane、拖动调整大小
set -g mouse on

# -------- 直观的切分按键 --------
# | 是竖线，表示左右切；- 是横线，表示上下切
unbind '"'
unbind %
bind | split-window -h -c "#{pane_current_path}"
bind - split-window -v -c "#{pane_current_path}"
bind c new-window -c "#{pane_current_path}"   # 新 window 也继承当前目录

# -------- 方向键 resize（可重复按） --------
bind -r H resize-pane -L 5
bind -r J resize-pane -D 5
bind -r K resize-pane -U 5
bind -r L resize-pane -R 5

# -------- vi 风格的复制模式 --------
setw -g mode-keys vi
bind -T copy-mode-vi v send-keys -X begin-selection
bind -T copy-mode-vi y send-keys -X copy-pipe-and-cancel "xclip -selection clipboard -i"

# -------- 快速重载配置 --------
bind r source-file ~/.tmux.conf \; display-message "tmux.conf reloaded."

# -------- 状态栏 --------
set -g status-interval 5
set -g status-left-length 30
set -g status-right-length 60
set -g status-left "#[fg=green]#S #[fg=white]| "
set -g status-right "#[fg=cyan]%Y-%m-%d %H:%M "

# https://gist.github.com/spicycode/1229612
# 不使用ctrl+B的前缀，直接用alt+方向键来切换面板
bind -n M-Left select-pane -L
bind -n M-Right select-pane -R
bind -n M-Up select-pane -U
bind -n M-Down select-pane -D

# 不适用ctrl+B的前缀，直接用shift+方向键来切换窗口
bind -n S-Left  previous-window
bind -n S-Right next-window

```

配置里的 `#{pane_current_path}` 是tmux的格式变量之一，用来拿当前pane的cwd。结合`new-window -c`、`split-window -c`用以后，开新pane直接就在当前目录里，不用再`cd`一遍。

## 插件管理：tpm + resurrect + continuum

tmux的插件生态靠 [tpm（tmux plugin manager）](https://github.com/tmux-plugins/tpm) 撑起来。装它：

```bash
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
```

然后在`.tmux.conf`末尾追加：

```tmux
# 插件列表
set -g @plugin 'tmux-plugins/tpm'
set -g @plugin 'tmux-plugins/tmux-sensible'
set -g @plugin 'tmux-plugins/tmux-resurrect'
set -g @plugin 'tmux-plugins/tmux-continuum'

# resurrect：保存更多内容（vim session、pane 内容等）
set -g @resurrect-capture-pane-contents 'on'
set -g @resurrect-strategy-vim 'session'

# continuum：开机自动恢复 + 每 15 分钟保存一次
set -g @continuum-restore 'on'
set -g @continuum-save-interval '15'

# 这一行必须放在文件最后
run '~/.tmux/plugins/tpm/tpm'
```

装好以后在tmux里按 ++ctrl+a++ ++I++（大写，前提是已经把前缀键改成了`C-a`）安装所有插件。`U` 是升级，`alt+u` 是卸载不在列表里的插件。

两个最值得装的插件：

* **tmux-resurrect**：手动保存/恢复 session。按 ++ctrl+a++ ++ctrl+s++ 存一次，按 ++ctrl+a++ ++ctrl+r++ 恢复。它会把所有window、pane的布局，正在跑的程序（可配置），甚至vim的session都保存下来。服务器重启后session原样回来，体验近乎魔法。
* **tmux-continuum**：resurrect 的自动化层，定期调用resurrect保存快照，并且在tmux server启动时自动恢复最近一次的快照。两个插件一起用，就有了「关掉不慌」的底气。

## 一些坑和细节

* **嵌套tmux**。本地开了个tmux再ssh进远端又开一个tmux，这时候两个tmux都抢前缀键 ++ctrl+a++。一个简单的绕开办法是连按两次前缀键：`send-prefix`会把第二个 ++ctrl+a++ 原样送给里层tmux，里层就收到前缀了。另一种做法是给里层tmux换一个前缀键。
* **tmux杀不掉僵死的client**。偶尔会遇到ssh断线但tmux没检测到，再attach的时候屏幕尺寸卡在老的尺寸，显示发虚。这时候在新attach的session里按 ++ctrl+a++ ++D++（大写，detach-client子命令）挑一个客户端踢掉；或者attach的时候就加`-d`强制踢别人。
* **复制出来是乱码**。多半是没开 `utf8`/locale 错了。确认`echo $LC_ALL $LANG`是UTF-8的，并且terminal emulator本身支持Unicode。
* **颜色不对**。`$TERM`在tmux内部会被设置成 `screen-256color` 或 `tmux-256color`。有些程序（比如vim的color scheme）在这两种下表现不一样。最稳的做法是按上面配置里那样显式设置`default-terminal`并加上`terminal-overrides`的`Tc`来开启真彩色。
* **`set -g` vs `setw -g`**。`set`管全局/server级别选项，`setw`（set-window-option的缩写）管窗口级别选项。大多数时候两者都能用`-g`加上，但涉及到window-specific的项（比如`mode-keys`、`window-status-*`）一定要用`setw`。
* **在脚本里启动tmux**。`tmux new -d -s work 'long-command.sh'`能以detach状态启动一个只跑某条命令的session，命令执行完session就退出。想让命令退出之后仍保留一个shell，可以在命令后面加`; bash`或者起一个空session再用`send-keys`发命令：

    ```bash
    tmux new -d -s work
    tmux send-keys -t work 'long-command.sh' C-m
    ```

    `C-m`就是回车。`send-keys`能做的事情很多，适合写一些自动布局的启动脚本。

## 一个典型的日常工作流

最后以一个常见的工作流串一下前面的知识点。假设要在一台远程服务器上跑一个很久的实验：

```bash
ssh server
tmux new -s exp              # 起一个叫 exp 的 session
# 窗口 1：跑实验
./run-experiment.sh
# 按 Ctrl+b c 新开一个窗口
nvidia-smi -l 2              # 这个 window 看 GPU
# 按 Ctrl+b c 再新开一个
tail -f logs/train.log       # 这个看日志
# 不想看了就 Ctrl+b d 离开
```

然后本地关掉ssh窗口，去吃饭。回来重新登录：

```bash
ssh server
tmux a -t exp
```

上面所有的window和pane原封不动出现在眼前，三个视角切过去都还在跑。等实验跑完，按 ++ctrl+b++ ++&++ 一个个关掉window，或者直接`tmux kill-session -t exp`一键清理。

用熟以后你会发现，服务器上几乎所有的事情都可以放在tmux里做——因为没有什么理由不这么做。
