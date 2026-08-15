#!/usr/bin/env bash
set -euo pipefail
STATE="${XDG_RUNTIME_DIR:-/tmp}/yusuf-game-mode"
if [[ "${1:-toggle}" != "toggle" ]]; then exit 2; fi
if [[ -f "$STATE" ]]; then
  rm -f "$STATE"
  hyprctl keyword animations:enabled true >/dev/null 2>&1 || true
  notify-send 'Oyun modu' 'Kapalı — normal Hyprland ayarları geri döndü.'
else
  : > "$STATE"
  hyprctl keyword animations:enabled false >/dev/null 2>&1 || true
  notify-send 'Oyun modu' 'Açık — animasyonlar kapalı, oyun için hazır.'
fi
