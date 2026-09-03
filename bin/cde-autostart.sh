#!/usr/bin/bash
# 会话自启：fcitx5、blueman（Xephyr / 独立 D-Bus）
set -u

export DISPLAY="${DISPLAY:-:33}"
export GDK_BACKEND=x11
unset WAYLAND_DISPLAY 2>/dev/null || true

CDE_XDG=/home/yang/git/fvwm/xdg-config

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
  XDG_CONFIG_HOME="$CDE_XDG" fcitx5 -d --disable=wayland \
    >/tmp/fvwm-fcitx-"${DISPLAY#:}".log 2>&1 || true
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
