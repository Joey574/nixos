#!/usr/bin/env bash
set -e
pushd /home/joey/repos/nixos/ > /dev/null

user="admin"
host=""
local_build=0
use_log=0
boot=0

usage() {
    echo "Usage: $0 [--local] [--log] [--boot] <host>"
    exit 1
}

while [ $# -gt 0 ]; do
    case "$1" in
        --local) local_build=1 ;;
        --log) use_log=1 ;;
        --boot) boot=1 ;;
        -*)
            echo "Unknown option: $1"
            usage
            ;;
        *)
            if [ -n "$host" ]; then
                echo "Multiple hosts given: $host, $1"
                usage
            fi
            host="$1"
            ;;
    esac
    shift
done

log="nixos-${host}.log"

if [ "$EUID" -ne 0 ]; then
  echo "Must run with sudo"
  exit 1
fi

if [ -z "$host" ]; then
  echo "Host not set"
  exit 1
fi

if [ "$host" == "desktop" ] || [ "$host" == "laptop" ]; then
  user="joey"
fi

log_format="bar"
[ "$use_log" -eq 1 ] && log_format="raw"

build_type="switch"
[ "$boot" -eq 1 ] && build_type="boot"

rebuild_args=(
    --target-host "$user@$host"
    --sudo --ask-sudo-password
    --log-format "$log_format"
    -I "nixos-config=./${host}/configuration.nix"
)

[ "$local_build" -eq 1 ] && rebuild_args+=(--option builders '')

[ $(hostname) != "desktop" ] && [ "$local_build" -ne 1 ] && rebuild_args+=(--build-host joey@desktop)

if [ "$use_log" -eq 1 ]; then
    set -o pipefail
    sudo -u joey nixos-rebuild "${build_type}" "${rebuild_args[@]}" 2>&1 | tee >(rotatelogs -n 3 "$log" 500K)
    set +o pipefail
else
    sudo -u joey nixos-rebuild "${build_type}" "${rebuild_args[@]}"
fi

# creates a local root node to avoid gc
if [ "$host" != "desktop" ] && [ $(hostname) == "desktop" ] ; then
    echo "creating local gc root..."
    path=$(sudo -u "joey" ssh "$user@$host" "readlink -f /run/current-system")
    ln -sfn "$path" "/nix/var/nix/gcroots/per-host/${host}"
fi

rm "$log*" 2>/dev/null || true
popd > /dev/null
