#!/usr/bin/env bash

# Seeds monitor's SSH host key into the freshly installed system

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
KEY="${SCRIPT_DIR}/../../tmp/monitor_ssh_host_ed25519_key"

if [[ ! -f ${KEY} ]]; then
  echo "host key not found at ${KEY}" >&2
  exit 1
fi

mkdir -p etc/ssh

install -m 0600 "${KEY}" ./etc/ssh/ssh_host_ed25519_key
ssh-keygen -y -f ./etc/ssh/ssh_host_ed25519_key >./etc/ssh/ssh_host_ed25519_key.pub
chmod 0644 ./etc/ssh/ssh_host_ed25519_key.pub
