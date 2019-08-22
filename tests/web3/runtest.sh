#!/usr/bin/env bash

set -euo pipefail

input_file="$1"  ; shift
output_file="$1" ; shift

# Start Firefly
PORT=$(tests/web3/get_port.py)
./kevm web3 "$PORT" "$@" &
kevm_client_pid="$!"
while ! netcat -z 127.0.0.1 "$PORT"; do sleep 0.1; done

# Feed input in, store output in tmp file
tmp_output_file="$(mktemp)"
trap "rm -rf $tmp_output_file" INT TERM EXIT
cat "$input_file" | netcat 127.0.0.1 "$PORT" -q 0 > "$tmp_output_file"

./kevm web3-send "$PORT" 'firefly_shutdown'
echo
timeout 20 tail --pid="$kevm_client_pid" -f /dev/null || true
pkill -P "$kevm_client_pid" kevm-client               || true
timeout 20 tail --pid="$kevm_client_pid" -f /dev/null || true

exit_code='0'
git --no-pager diff --no-index "$output_file" "$tmp_output_file" || exit_code="$?"

exit "$exit_code"