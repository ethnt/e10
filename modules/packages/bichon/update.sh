#!/usr/bin/env nix-shell
#! nix-shell -i bash -p curl jq nix nurl git gnused

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
DEFAULT_NIX="$SCRIPT_DIR/default.nix"
REPO_ROOT="$(git -C "$SCRIPT_DIR" rev-parse --show-toplevel)"

FAKE_HASH="sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA="

echo "==> Fetching latest bichon release..." >&2

release_json="$(curl -fsSL https://api.github.com/repos/rustmailer/bichon/releases/latest)"
tag="$(jq -r '.tag_name' <<<"$release_json")"

if [ -z "$tag" ] || [ "$tag" = "null" ]; then
  echo "Could not determine latest release tag" >&2
  exit 1
fi

# bichon tags (and the fetchFromGitHub rev) are the bare version, e.g. "2.0.2".
version="${tag#v}"

echo "  Tag: ${tag}" >&2
echo "  Version: ${version}" >&2

# Build the given flake target (a fixed-output derivation) and pull the correct
# hash out of the mismatch error. Expects the build to fail because the hash is
# currently FAKE_HASH.
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

# Grab the current hashes. There are two `hash = "..."` lines: the first is the
# `src` (fetchFromGitHub) hash, the second is the frontend `pnpmDeps` hash.
old_src_hash="$(sed -n 's/.*hash = "\(sha256-[^"]*\)".*/\1/p' "$DEFAULT_NIX" | sed -n '1p')"
old_pnpm_hash="$(sed -n 's/.*hash = "\(sha256-[^"]*\)".*/\1/p' "$DEFAULT_NIX" | sed -n '2p')"
old_cargo_hash="$(sed -n 's/.*cargoHash = "\(sha256-[^"]*\)".*/\1/p' "$DEFAULT_NIX")"

echo "==> Updating version..." >&2
sed -i "s|version = \"[^\"]*\"|version = \"${version}\"|" "$DEFAULT_NIX"

echo "==> Computing src hash with nurl..." >&2
new_src_hash="$(nurl https://github.com/rustmailer/bichon "$version" -H)"
sed -i "s|${old_src_hash}|${new_src_hash}|" "$DEFAULT_NIX"
echo "  src hash: ${new_src_hash}" >&2

echo "==> Computing cargoHash..." >&2
sed -i "s|${old_cargo_hash}|${FAKE_HASH}|" "$DEFAULT_NIX"
new_cargo_hash="$(got_hash "$REPO_ROOT#bichon.cargoDeps")"
sed -i "s|${FAKE_HASH}|${new_cargo_hash}|" "$DEFAULT_NIX"
echo "  cargoHash: ${new_cargo_hash}" >&2

echo "==> Computing frontend pnpmDeps hash..." >&2
sed -i "s|${old_pnpm_hash}|${FAKE_HASH}|" "$DEFAULT_NIX"
new_pnpm_hash="$(got_hash "$REPO_ROOT#bichon.frontend.pnpmDeps")"
sed -i "s|${FAKE_HASH}|${new_pnpm_hash}|" "$DEFAULT_NIX"
echo "  pnpmDeps hash: ${new_pnpm_hash}" >&2

echo "Done." >&2
