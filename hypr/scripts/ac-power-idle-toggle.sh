#!/usr/bin/env bash

# Guard idle actions when AC no-idle mode is enabled.

STATE_DIR="${XDG_STATE_HOME:-$HOME/.local/state}"
STATE_FILE="$STATE_DIR/ac_no_idle_mode_enabled"

mkdir -p "$STATE_DIR"

is_on_ac() {
  for supply in /sys/class/power_supply/*; do
    [ -d "$supply" ] || continue

    if [ -r "$supply/type" ] && [ "$(cat "$supply/type" 2>/dev/null)" = "Mains" ]; then
      [ -r "$supply/online" ] || continue
      [ "$(cat "$supply/online" 2>/dev/null)" = "1" ] && return 0
    fi
  done

  return 1
}

is_mode_enabled() {
  # Default to enabled so AC no-idle mode works immediately after deploy.
  [ ! -f "$STATE_FILE" ] && return 0
  [ "$(cat "$STATE_FILE" 2>/dev/null)" = "1" ]
}

set_mode() {
  printf "%s\n" "$1" > "$STATE_FILE"
}

should_skip_idle_actions() {
  is_mode_enabled && is_on_ac
}

toggle_mode() {
  if is_mode_enabled; then
    set_mode "0"
  else
    set_mode "1"
  fi
}

print_status_json() {
  local text class tooltip

  if is_mode_enabled; then
    if is_on_ac; then
      text=" no-idle"
      class="active"
      tooltip="AC no-idle enabled: lock, screen-off, and suspend are disabled."
    else
      text=" no-idle"
      class="armed"
      tooltip="AC no-idle enabled: it will apply when AC is connected."
    fi
  else
    if is_on_ac; then
      text=" idle"
    else
      text=" idle"
    fi

    class="inactive"
    tooltip="Normal idle behavior enabled."
  fi

  printf '{"text":"%s","class":"%s","tooltip":"%s"}\n' "$text" "$class" "$tooltip"
}

case "${1:-status-json}" in
  lock|before-sleep)
    should_skip_idle_actions && exit 0
    loginctl lock-session
    ;;
  dpms-off)
    should_skip_idle_actions && exit 0
    hyprctl dispatch dpms off
    ;;
  suspend)
    should_skip_idle_actions && exit 0
    systemctl suspend
    ;;
  toggle)
    toggle_mode
    ;;
  enable)
    set_mode "1"
    ;;
  disable)
    set_mode "0"
    ;;
  status-json)
    print_status_json
    ;;
  *)
    echo "Usage: $0 {lock|before-sleep|dpms-off|suspend|toggle|enable|disable|status-json}" >&2
    exit 1
    ;;
esac
