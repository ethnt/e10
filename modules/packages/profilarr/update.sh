#!/usr/bin/env nix-shell
#! nix-shell -i bash -p curl jq nix nurl git gnused

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
DEFAULT_NIX="$SCRIPT_DIR/default.nix"
REPO_ROOT="$(git -C "$SCRIPT_DIR" rev-parse --show-toplevel)"

FAKE_HASH="sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA="

# denoDeps is hashed per-platform, so it must be built for each of these.
# aarch64-linux needs an aarch64-capable builder (native, remote, or binfmt).
SYSTEMS=(x86_64-linux aarch64-linux)

echo "==> Fetching latest Profilarr release..." >&2

release_json="$(curl -fsSL https://api.github.com/repos/Dictionarry-Hub/Profilarr/releases/latest)"
tag="$(jq -r '.tag_name' <<<"$release_json")"

if [ -z "$tag" ] || [ "$tag" = "null" ]; then
  echo "Could not determine latest release tag" >&2
  exit 1
fi

version="${tag#v}"

echo "  Tag: ${tag}" >&2
echo "  Version: ${version}" >&2

# Build the given flake target (the denoDeps FOD, exposed via passthru) and pull
# the correct hash out of the fixed-output mismatch error. Expects the build to
# fail because the hash is currently FAKE_HASH.
got_hash() {
  local target="$1" out hash
  out="$(nix build "$target" --no-link 2>&1 || true)"
  hash="$(grep -oE 'got:[[:space:]]+sha256-[A-Za-z0-9+/=]+' <<<"$out" | head -n1 | sed -E 's/got:[[:space:]]+//')"
  if [ -z "$hash" ]; then
    echo "Could not extract hash from build output:" >&2
    echo "$out" >&2
    exit 1
  fi
  echo "$hash"
}

echo "==> Updating version..." >&2
sed -i "s|version = \"[^\"]*\"|version = \"${version}\"|" "$DEFAULT_NIX"

echo "==> Computing src hash with nurl..." >&2
old_src_hash="$(sed -n 's/.*hash = "\(sha256-[^"]*\)".*/\1/p' "$DEFAULT_NIX")"
new_src_hash="$(nurl https://github.com/Dictionarry-Hub/Profilarr "$tag" -H)"
sed -i "s|${old_src_hash}|${new_src_hash}|" "$DEFAULT_NIX"
echo "  src hash: ${new_src_hash}" >&2

for system in "${SYSTEMS[@]}"; do
  echo "==> Computing denoDeps hash for ${system}..." >&2
  old_hash="$(sed -n "s/.*${system} = \"\(sha256-[^\"]*\)\".*/\1/p" "$DEFAULT_NIX")"
  sed -i "s|${old_hash}|${FAKE_HASH}|" "$DEFAULT_NIX"
  new_hash="$(got_hash "$REPO_ROOT#packages.${system}.profilarr.denoDeps")"
  sed -i "s|${FAKE_HASH}|${new_hash}|" "$DEFAULT_NIX"
  echo "  ${system}: ${new_hash}" >&2
done

echo "Done." >&2
