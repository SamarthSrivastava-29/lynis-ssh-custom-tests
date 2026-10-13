#!/usr/bin/env bash
# Standalone reference checker for three SSH login settings.
# This is NOT a Lynis plugin; tests_custom is the Lynis integration file.
set -u
CONFIG="${1:-/etc/ssh/sshd_config}"
if [[ ! -r "$CONFIG" ]]; then
  echo "Cannot read $CONFIG. Try: sudo $0"
  exit 1
fi
check_setting() {
  local key="$1" expected="$2" value
  value=$(awk -v key="$key" 'tolower($1)==tolower(key) {v=$2} END {print v}' "$CONFIG")
  if [[ "$value" == "$expected" ]]; then
    printf '[ OK ] %s=%s\n' "$key" "$value"
  else
    printf '[ REVIEW ] %s is %s; expected explicit value %s\n' "$key" "${value:-unset}" "$expected"
  fi
}
check_setting PermitRootLogin no
check_setting PasswordAuthentication no
check_setting PermitEmptyPasswords no
echo "Note: This checks explicit lines in $CONFIG only, not the effective OpenSSH configuration."
