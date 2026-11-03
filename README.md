# fvwm

精简的 **fvwm** 配置（语法兼顾 fvwm3 与 2.7）：Motif / CDE 装饰 + 标题栏，配合 rofi。不做 dock / 面板 / 桌面图标。

## 依赖

- **WM**：`fvwm3`（Arch）或 `fvwm`（Alpine 2.7）；`fvwm-session` 优先前者
- `rofi`（应用启动、窗口列表）
- 默认终端命令 `alacritty`（可用本机 `local.conf` 改成 `st` 等，见下）
- `JetBrainsMono Nerd Font`（窗口菜单字形）
- 可选：`fcitx5`、`blueman`（见 `bin/cde-autostart.sh`）

## 安装

```bash
./install.sh                 # 默认 symlink → ~/.fvwm
./install.sh --copy          # 拷贝整树
./install.sh --force         # 冲突时备份后覆盖
# 父仓 dotfiles：
./install.sh desktop:fvwm
```

## 使用

```bash
fvwm-session                 # 推荐：dbus + fvwm3|fvwm -f ~/.fvwm/config
startx fvwm                  # multistart → fvwm-session
fvwm3 -f ~/.fvwm/config      # 仅 WM（或 Alpine: fvwm -f …）
```

嵌套测试：

```bash
Xephyr :33 -screen 1904x1116 &
DISPLAY=:33 FVWM_USERDIR="$PWD" fvwm3 -f "$PWD/config"
# Alpine 2.7：把 fvwm3 换成 fvwm
```

入口为仓库根目录 `config`，经 `$[FVWM_USERDIR]` 加载 `conf.d/`。最后可选读本机私货（**不在仓库里**）：

```bash
mkdir -p ~/.config/fvwm
cp /path/to/fvwm/local.conf.example ~/.config/fvwm/local.conf
# 编辑：SetEnv term st
```

`~/.fvwm` 若是指向 git 的 symlink，把私货放在 `~/.config/fvwm/local.conf`，更新 dotfiles 不会覆盖。

## 目录

| 路径 | 说明 |
|------|------|
| `config` | 主配置入口（末尾 PipeRead 本机 local.conf） |
| `local.conf.example` | 本机覆盖示例（复制到 `~/.config/fvwm/local.conf`） |
| `conf.d/00-base.conf` | 桌面、启动函数 |
| `conf.d/10-colorsets.conf` | 配色 |
| `conf.d/20-decor-cde.conf` | CDE / Motif 装饰与按钮 |
| `conf.d/30-bindings-window.conf` | 标题栏 / 边框鼠标 |
| `conf.d/40-styles.conf` | 窗口样式；新窗口 `GrabFocus` |
| `conf.d/50-keys.conf` | 快捷键（`SetEnv term`） |
| `conf.d/60-menus.conf` | 菜单样式（Nerd Font） |
| `conf.d/62-menu-windowops.conf` | 标题栏窗口菜单 |
| `conf.d/80-autostart.conf` | 延迟自启 |
| `bin/cde-autostart.sh` | fcitx5 / blueman |
| `rofi/cde.rasi` | rofi CDE 灰绿主题 |

## 快捷键

默认修饰键为 **Alt**（`modkey = M`，可在 `50-keys.conf` 修改）。

| 快捷键 | 作用 |
|--------|------|
| Alt + Return | 终端（默认 `alacritty`，`$[term]`） |
| Alt + Space | rofi 应用启动 |
| Alt + Tab | rofi 窗口切换 |
| Alt + m | 最大化 |
| Alt + i | 最小化 |
| Alt + q | 关闭窗口 |
| Alt + Shift + m / s | 移动 / 调整大小 |
| Alt + Shift + q | 退出 fvwm |
| Alt + Shift + r | 重载配置 |

标题栏左侧按钮打开窗口菜单；无桌面根菜单。

## 说明

- 新映射窗口会抢焦点（`GrabFocus`），不要求指针在窗口上。
- 菜单图标使用 Nerd Font 字符，不依赖仓库内 PNG。
- 无 Front Panel / lemonbar / dock；需要状态栏请自行外挂。
