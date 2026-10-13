#!/usr/bin/env bash
# Standalone reference checker for SSH attempts, liveness and port.
# This is NOT a Lynis plugin; tests_custom is the Lynis integration file.
set -u
CONFIG="${1:-/etc/ssh/sshd_config}"
if [[ ! -r "$CONFIG" ]]; then
  echo "Cannot read $CONFIG. Try: sudo $0"
  exit 1
fi
get_value() {
  awk -v key="$1" 'tolower($1)==tolower(key) {v=$2} END {print v}' "$CONFIG"
}
tries=$(get_value MaxAuthTries)
interval=$(get_value ClientAliveInterval)
countmax=$(get_value ClientAliveCountMax)
port=$(get_value Port)
if [[ "$tries" =~ ^[0-9]+$ ]] && (( tries <= 4 )); then
  echo "[ OK ] MaxAuthTries=$tries"
else
  echo "[ REVIEW ] MaxAuthTries=${tries:-unset} (target: 4 or fewer)"
fi
if [[ "$interval" =~ ^[0-9]+$ && "$countmax" =~ ^[0-9]+$ ]] && (( interval > 0 )); then
  echo "[ OK ] ClientAliveInterval=$interval ClientAliveCountMax=$countmax"
else
  echo "[ REVIEW ] ClientAliveInterval=${interval:-unset} ClientAliveCountMax=${countmax:-unset}"
fi
if [[ -n "$port" && "$port" != "22" ]]; then
  echo "[ INFO ] Explicit SSH Port=$port (review firewall and client configuration)"
else
  echo "[ SUGGESTION ] SSH port appears to be default or unset"
fi
echo "Note: This checks explicit lines in $CONFIG only, not the effective OpenSSH configuration."
