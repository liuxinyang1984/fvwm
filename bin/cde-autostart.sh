#!/usr/bin/bash
# 会话自启：fcitx5、blueman、壁纸（Xephyr / 独立 D-Bus）
set -u

export DISPLAY="${DISPLAY:-:0}"
export GDK_BACKEND=x11
unset WAYLAND_DISPLAY 2>/dev/null || true

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
CDE_XDG="${ROOT}/xdg-config"
WALLPAPER_DIR="${HOME}/Pictures/wallpapers"

exec 8>"/tmp/fvwm-autostart-${DISPLAY#:}.lock"
flock -n 8 || exit 0

pids_on_display() {
  local name="$1" pid d
  for pid in $(pgrep -x "$name" 2>/dev/null); do
    d=$(tr '\0' '\n' <"/proc/$pid/environ" 2>/dev/null | sed -n 's/^DISPLAY=//p' | head -1)
    if [ "$d" = "$DISPLAY" ]; then
      echo "$pid"
    fi
  done
}

kill_on_display() {
  local pid
  for pid in $(pids_on_display "$1"); do
    kill "$pid" 2>/dev/null || true
  done
}

kill_on_display fcitx5
sleep 0.3
if [ -z "$(pids_on_display fcitx5)" ]; then
  if [ -d "$CDE_XDG" ]; then
    XDG_CONFIG_HOME="$CDE_XDG" fcitx5 -d --disable=wayland \
      >/tmp/fvwm-fcitx-"${DISPLAY#:}".log 2>&1 || true
  else
    fcitx5 -d --disable=wayland \
      >/tmp/fvwm-fcitx-"${DISPLAY#:}".log 2>&1 || true
  fi
fi

kill_on_display blueman-tray
kill_on_display blueman-applet
sleep 0.3
old_plugins=$(gsettings get org.blueman.general plugin-list 2>/dev/null || echo "@as []")
gsettings set org.blueman.general plugin-list "['!StatusNotifierItem']" 2>/dev/null || true
blueman-applet >/tmp/fvwm-blueman-"${DISPLAY#:}".log 2>&1 &
sleep 1
gsettings set org.blueman.general plugin-list "$old_plugins" 2>/dev/null || \
  gsettings set org.blueman.general plugin-list "[]" 2>/dev/null || true

if command -v feh >/dev/null 2>&1; then
  if [ -f "${WALLPAPER_DIR}/girl.png" ]; then
    feh --bg-fill "${WALLPAPER_DIR}/girl.png" || true
  elif ls "${WALLPAPER_DIR}/"* >/dev/null 2>&1; then
    feh --bg-fill --randomize "${WALLPAPER_DIR}/"* || true
  fi
fi
