#!/usr/bin/env nix-shell
#! nix-shell -i bash -p curl jq nix binwalk coreutils findutils gnused

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
DEFAULT_NIX="$SCRIPT_DIR/default.nix"

echo "==> Fetching latest UniFi OS Server x86_64-linux installer..." >&2

API_JSON="$(curl -fsSL https://download.svc.ui.com/v1/downloads/products/slugs/unifi-os-server)"

download_json="$(jq -c '[.downloads[] | select(.name | test("UniFi OS Server .* for Linux \\(x64\\)$"))] | max_by(.date_published) // empty' <<<"$API_JSON")"

if [ -z "$download_json" ] || [ "$download_json" = "null" ]; then
  echo "Could not find x86_64-linux installer in API response" >&2
  exit 1
fi

installer_version="$(jq -r '.version' <<<"$download_json")"
url="$(jq -r '.file_url' <<<"$download_json")"

echo "  Version: ${installer_version}" >&2
echo "  URL: ${url}" >&2
echo "==> Downloading installer and computing hash..." >&2

work="$(mktemp -d)"
trap 'rm -rf "$work"' EXIT

curl -fsSL "$url" -o "$work/installer"

sha256="sha256-$(nix hash file --type sha256 --base64 "$work/installer")"

echo "  SHA256: ${sha256}" >&2
echo "==> Extracting image version..." >&2

chmod u+w "$work/installer"
(cd "$work" && binwalk --threads 1 -e ./installer >/dev/null)

image_tar="$(find "$work" -type f -name image.tar | head -n1)"
if [ -z "$image_tar" ]; then
  echo "Could not find embedded image.tar in installer" >&2
  exit 1
fi

mkdir -p "$work/extracted"
tar -xf "$image_tar" -C "$work/extracted"

image_version="$(jq -r '.[0].RepoTags[0]' "$work/extracted/manifest.json" | cut -d: -f2)"

echo "  Image version: ${image_version}" >&2
echo "==> Updating default.nix..." >&2

sed -i \
  -e "s|imageVersion = \"[^\"]*\"|imageVersion = \"${image_version}\"|" \
  -e "s|installerVersion = \"[^\"]*\"|installerVersion = \"${installer_version}\"|" \
  -e "s|url = \"[^\"]*\"|url = \"${url}\"|" \
  -e "s|sha256 = \"[^\"]*\"|sha256 = \"${sha256}\"|" \
  "$DEFAULT_NIX"

echo "Done." >&2
