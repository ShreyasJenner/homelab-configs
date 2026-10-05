#!/usr/bin/env bash
# Manage the docker compose stacks that live in subfolders next to this script.
#
# Usage: ./stacks.sh <command> [stack ...]
#   With no stack names, the command applies to every stack in DEFAULT_STACKS.

set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Folder names (relative to this script) that count as "all stacks".
# Remove or comment out any you don't want started by default.
DEFAULT_STACKS=(
  euro-office
  slskd
  navidrome
  nextcloud
  actual-budget
  invidious
  mindwtr
  jellyfin
  kavita
  qbittorrent
  redlib
  materialious
  ntfy
  uptime-kuma
  monitoring
)



usage() {
  cat <<EOF
Usage: $(basename "$0") <command> [stack ...]

Commands:
  up        Start stacks (docker compose up -d)
  stop      Stop containers, keep them around
  down      Stop and remove containers and networks (volumes/bind mounts are kept)
  restart   Restart containers (does NOT pick up compose file changes; use up)
  pull      Pull newer images
  update    pull, then up -d
  ps        Show container status
  logs      Follow logs (-f --tail 50)
  list      Show the default stacks

Examples:
  $(basename "$0") up navidrome donetick
  $(basename "$0") update
  $(basename "$0") logs slskd
EOF
}

if [[ $# -lt 1 ]]; then
  usage
  exit 1
fi

cmd="$1"
shift

if [[ "$cmd" == "list" ]]; then
  printf '%s\n' "${DEFAULT_STACKS[@]}"
  exit 0
fi

if [[ $# -gt 0 ]]; then
  stacks=("$@")
else
  stacks=("${DEFAULT_STACKS[@]}")
fi

run_in() {
  local name="$1"
  shift
  local dir="$ROOT/$name"
  if [[ ! -d "$dir" ]]; then
    echo "!! $name: no such folder $dir" >&2
    return 1
  fi
  local f found=0
  for f in docker-compose.yml docker-compose.yaml compose.yml compose.yaml; do
    if [[ -f "$dir/$f" ]]; then found=1; fi
  done
  if [[ $found -eq 0 ]]; then
    echo "!! $name: no compose file found in $dir" >&2
    return 1
  fi
  (cd "$dir" && docker compose "$@")
}

failed=0
for s in "${stacks[@]}"; do
  echo "==> $s: $cmd"
  case "$cmd" in
    up)      run_in "$s" up -d ;;
    stop)    run_in "$s" stop ;;
    down)    run_in "$s" down ;;
    restart) run_in "$s" restart ;;
    pull)    run_in "$s" pull ;;
    update)  run_in "$s" pull && run_in "$s" up -d ;;
    ps)      run_in "$s" ps ;;
    logs)    run_in "$s" logs -f --tail 50 ;;
    *)       usage; exit 1 ;;
  esac || { echo "!! $s failed" >&2; failed=1; }
done

exit "$failed"
