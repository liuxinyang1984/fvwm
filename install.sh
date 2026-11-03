#!/bin/sh
# 把本仓落到 ~/.fvwm（fvwm3 默认 FVWM_USERDIR）
#   ./install.sh           # 默认 symlink（改仓即生效）
#   ./install.sh --copy    # 拷贝整树（不含 .git）
#   ./install.sh --force   # 目标冲突时备份后覆盖（默认/拷贝均适用）
# 父仓: ./install.sh desktop:fvwm（FVWM_FORCE=1 → --force；FVWM_COPY=1 → --copy）
set -e
ROOT="$(cd "$(dirname "$0")" && pwd)"
DEST="${FVWM_HOME:-$HOME/.fvwm}"
MODE=link
FORCE=0

usage() {
	cat <<'EOF'
用法: ./install.sh [--copy|--force]

  （默认）  symlink 本仓库 → ~/.fvwm（可用 FVWM_HOME 改目标）
  --copy    拷贝整树到目标（排除 .git）
  --force   目标已存在且不是本仓链接时：备份后重建
  -h        帮助

启动: fvwm-session / startx fvwm（需 ~/.local/bin/fvwm-session）
EOF
}

for arg in "$@"; do
	case "$arg" in
	--copy) MODE=copy ;;
	--force) FORCE=1 ;;
	-h|--help) usage; exit 0 ;;
	*)
		echo "未知参数: $arg" >&2
		usage >&2
		exit 1
		;;
	esac
done

[ -f "$ROOT/config" ] || { echo "缺少 $ROOT/config" >&2; exit 1; }
chmod +x "$ROOT/bin/"*.sh "$ROOT/bin/fvwm-session" 2>/dev/null || true
BIN_DIR="${FVWM_SESSION_BIN:-$HOME/.local/bin}"
X11_COMMON_DEST="${XDG_CONFIG_HOME:-$HOME/.config}/x11/session-common.sh"

backup_dest() {
	backup="${DEST}.backup.$(date +%Y%m%d%H%M%S)"
	mv "$DEST" "$backup"
	echo "已备份 $DEST → $backup"
}

prepare_dest() {
	if [ -L "$DEST" ]; then
		cur="$(readlink "$DEST")"
		if [ "$MODE" = link ] && [ "$cur" = "$ROOT" ]; then
			echo "已正确链接: $DEST → $ROOT"
			return 1
		fi
		if [ "$FORCE" = 1 ]; then
			rm -f "$DEST"
			return 0
		fi
		echo "警告: $DEST → $cur。加 --force 覆盖，或 FVWM_HOME=… 另选目录" >&2
		exit 1
	fi
	if [ -e "$DEST" ]; then
		if [ "$FORCE" = 1 ]; then
			backup_dest
			return 0
		fi
		echo "警告: $DEST 已存在。加 --force 备份后安装" >&2
		exit 1
	fi
	return 0
}

if prepare_dest; then
	mkdir -p "$(dirname "$DEST")"
	if [ "$MODE" = link ]; then
		ln -sfn "$ROOT" "$DEST"
		echo "symlink $DEST → $ROOT"
	else
		mkdir -p "$DEST"
		# 优先 rsync；否则 tar 管道
		if command -v rsync >/dev/null 2>&1; then
			rsync -a --delete --exclude .git --exclude .git/ "$ROOT"/ "$DEST"/
		else
			(cd "$ROOT" && tar cf - --exclude .git .) | (cd "$DEST" && tar xf -)
		fi
		chmod +x "$DEST/bin/"*.sh 2>/dev/null || true
		echo "copy $ROOT → $DEST"
	fi
fi

# 会话入口 → ~/.local/bin/fvwm-session（multistart: startx fvwm）
mkdir -p "$BIN_DIR"
if [ -f "$ROOT/bin/fvwm-session" ]; then
	if [ "$MODE" = link ]; then
		ln -sfn "$ROOT/bin/fvwm-session" "$BIN_DIR/fvwm-session"
		echo "symlink $BIN_DIR/fvwm-session → $ROOT/bin/fvwm-session"
	else
		cp -f "$ROOT/bin/fvwm-session" "$BIN_DIR/fvwm-session"
		chmod +x "$BIN_DIR/fvwm-session"
		echo "copy $BIN_DIR/fvwm-session"
	fi
fi
# 若父仓 session-common 已由其它模块装好则跳过；否则提示
if [ ! -e "$X11_COMMON_DEST" ]; then
	echo "提示: 无 $X11_COMMON_DEST（可选: ./install.sh x11:multistart 或 desktop:kiosk/suckless）" >&2
fi

missing=""
if ! command -v fvwm3 >/dev/null 2>&1 && ! command -v fvwm >/dev/null 2>&1; then
	missing="$missing fvwm3|fvwm"
fi
command -v rofi >/dev/null 2>&1 || missing="$missing rofi"
[ -n "$missing" ] && echo "警告: 未在 PATH 找到:$missing（Arch: fvwm3；Alpine: fvwm）" >&2

echo "fvwm → $DEST（mode=$MODE）"
echo "  fvwm-session / startx fvwm（优先 fvwm3，否则 fvwm）"
