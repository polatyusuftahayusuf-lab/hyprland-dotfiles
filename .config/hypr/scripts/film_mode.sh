#!/usr/bin/env bash
set -euo pipefail
STATE="${XDG_RUNTIME_DIR:-/tmp}/yusuf-film-mode"
if [[ "${1:-toggle}" != "toggle" ]]; then exit 2; fi
if [[ -f "$STATE" ]]; then
  rm -f "$STATE"
  hyprctl keyword animations:enabled true >/dev/null 2>&1 || true
  hyprctl keyword decoration:blur:enabled true >/dev/null 2>&1 || true
  notify-send 'Film modu' 'Kapalı — normal Hyprland ayarları geri döndü.'
else
  : > "$STATE"
  hyprctl keyword animations:enabled false >/dev/null 2>&1 || true
  hyprctl keyword decoration:blur:enabled false >/dev/null 2>&1 || true
  notify-send 'Film modu' 'Açık — Super+P film paneli hazır; animasyon ve blur kapalı.'
fi
