#!/usr/bin/env nix-shell
#! nix-shell -i bash -p curl jq nix git gzip gnutar gnugrep gnused coreutils

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
DEFAULT_NIX="$SCRIPT_DIR/default.nix"
REPO_ROOT="$(git -C "$SCRIPT_DIR" rev-parse --show-toplevel)"

IMAGE_REPO="connorgallopo/tracearr"
BASEMAP_PATH="app/data/basemap.pmtiles"
FAKE_HASH="sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA="

PROBE_ENTRIES=32

system="$(nix eval --impure --raw --expr 'builtins.currentSystem')"

version="${1:-$(nix eval --raw "$REPO_ROOT#packages.${system}.tracearr.version")}"

echo "==> Resolving basemap layer for Tracearr ${version}..." >&2

curlOpts=(--silent --show-error --fail --location)

token="$(curl "${curlOpts[@]}" \
  "https://ghcr.io/token?scope=repository:${IMAGE_REPO//\//%2F}:pull&service=ghcr.io" \
  | jq -r .token)"
auth="Authorization: Bearer $token"

index="$(curl "${curlOpts[@]}" -H "$auth" \
  -H "Accept: application/vnd.oci.image.index.v1+json" \
  "https://ghcr.io/v2/${IMAGE_REPO}/manifests/${version}")"

manifest_digest="$(jq -r '.manifests[] | select(.platform.architecture == "amd64") | .digest' <<<"$index")"

if [ -z "$manifest_digest" ] || [ "$manifest_digest" = "null" ]; then
  echo "No amd64 manifest for tag ${version}" >&2
  exit 1
fi

manifest="$(curl "${curlOpts[@]}" -H "$auth" \
  -H "Accept: application/vnd.oci.image.manifest.v1+json" \
  "https://ghcr.io/v2/${IMAGE_REPO}/manifests/${manifest_digest}")"

layer_has_basemap() {
  local digest="$1" entries

  entries="$( {
    curl "${curlOpts[@]}" -H "$auth" \
      "https://ghcr.io/v2/${IMAGE_REPO}/blobs/${digest}" \
      | gzip -dc | tar -t | head -n "$PROBE_ENTRIES"
  } 2>/dev/null || true )"

  grep -qxF "$BASEMAP_PATH" <<<"$entries"
}

layer_digest=""

while read -r size digest media_type; do
  if [ "$media_type" != "application/vnd.oci.image.layer.v1.tar+gzip" ] \
    && [ "$media_type" != "application/vnd.docker.image.rootfs.diff.tar.gzip" ]; then
    continue
  fi

  echo "  probing ${digest} (${size} bytes)" >&2

  if layer_has_basemap "$digest"; then
    layer_digest="$digest"
    break
  fi
done < <(jq -r '.layers | sort_by(-.size)[] | "\(.size)\t\(.digest)\t\(.mediaType)"' <<<"$manifest")

if [ -z "$layer_digest" ]; then
  echo "No gzipped layer in ${IMAGE_REPO}:${version} contains ${BASEMAP_PATH}" >&2
  echo "If upstream switched the layer compression, buildCommand in default.nix needs updating too" >&2
  exit 1
fi

echo "  layer: ${layer_digest}" >&2

old_digest="$(sed -n 's/.*layerDigest = "\([^"]*\)".*/\1/p' "$DEFAULT_NIX")"

sed -i \
  -e "s|version = \"[^\"]*\"|version = \"${version}\"|" \
  -e "s|layerDigest = \"[^\"]*\"|layerDigest = \"${layer_digest}\"|" \
  "$DEFAULT_NIX"

if [ "$layer_digest" = "$old_digest" ]; then
  echo "  layer unchanged, keeping outputHash" >&2
  echo "Done." >&2
  exit 0
fi

echo "==> Computing outputHash (downloads ~550 MB)..." >&2

sed -i "s|outputHash = \"[^\"]*\"|outputHash = \"${FAKE_HASH}\"|" "$DEFAULT_NIX"

out="$(nix build "$REPO_ROOT#packages.${system}.tracearr-basemap" --no-link 2>&1 || true)"
new_hash="$(grep -oE 'got:[[:space:]]+sha256-[A-Za-z0-9+/=]+' <<<"$out" | head -n1 | sed -E 's/got:[[:space:]]+//')"

if [ -z "$new_hash" ]; then
  echo "Could not extract hash from build output:" >&2
  echo "$out" >&2
  exit 1
fi

sed -i "s|${FAKE_HASH}|${new_hash}|" "$DEFAULT_NIX"

echo "  outputHash: ${new_hash}" >&2
echo "Done." >&2
