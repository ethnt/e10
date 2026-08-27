#!/usr/bin/env nix-shell
#! nix-shell -i bash -p curl jq nix gnugrep gnused

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
DEFAULT_NIX="$SCRIPT_DIR/default.nix"

echo "==> Determining latest FileFlows version..." >&2

version="$(curl -fsSL -r 0-0 -o /dev/null -D - "https://fileflows.com/downloads/ff-latest.tar.xz" \
  | grep -i '^etag:' | grep -oE '[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+' | head -n1)"

if [ -z "$version" ]; then
  echo "Could not determine latest version from ff-latest.tar.xz ETag" >&2
  exit 1
fi

echo "  Version: ${version}" >&2

echo "==> Computing src hash..." >&2
url="https://fileflows.com/downloads/TarXz/${version}"
new_hash="$(nix store prefetch-file --unpack --hash-type sha256 --json "$url" | jq -r '.hash')"

echo "  src hash: ${new_hash}" >&2

echo "==> Updating default.nix..." >&2
old_hash="$(sed -n 's/.*hash = "\(sha256-[^"]*\)".*/\1/p' "$DEFAULT_NIX")"
sed -i \
  -e "s|version = \"[^\"]*\"|version = \"${version}\"|" \
  -e "s|${old_hash}|${new_hash}|" \
  "$DEFAULT_NIX"

echo "Done." >&2
