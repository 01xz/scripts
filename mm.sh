#!/bin/zsh
# mm - measure memory usage of processes
# usage: mm COMMAND [ARGS]...

set -um

# check input
[[ $# -gt 0 ]] || { sed -n '2,/^#$/ s/^# //p' <"$0"; exit 1; }

pgid=$(ps -o pgid= $$)
# make sure we're in a separate process group
if [[ "$pgid" == "$(ps -o pgid= $(ps -o ppid= $$))" ]]; then
  cmd=
  set -- "$0" "$@"
  for a; do cmd+="'${a//"'"/"'\\''"}' "; done
  exec bash -i -c "$cmd"
fi

# detect operating system and prepare measurement
case $(uname) in
  Darwin|*BSD) sizes() { /bin/ps -o rss= -g $1; } ;;
  Linux) sizes() { /bin/ps -o rss= -$1; } ;;
  *) echo "$(uname): unsupported operating system" >&2; exit 2 ;;
esac

# monitor the memory usage in the background.
(
  peak=0
  while sizes=$(sizes $pgid)
  do
    set -- $sizes
    sample=$((${@/#/+}))
    let peak="sample > peak ? sample : peak"
    sleep 0.1
  done
  echo "Memory usage (KiB): peak=$peak" >&2
) &
monpid=$!

# run the given command
exec "$@"

