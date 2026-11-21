#!/usr/bin/env bash
set -euo pipefail

# The desktop app's own electron-updater feed: version + sha512 of every artifact.
FEED="https://downloads.capy.ai/stable"
MANIFEST=$(curl -sSf "$FEED/latest-mac.yml")
VERSION=$(awk '/^version:/ {print $2; exit}' <<<"$MANIFEST")

if [ -z "$VERSION" ]; then
  echo "No version found in $FEED/latest-mac.yml" >&2
  exit 1
fi

if [ -f "versions/${VERSION}.json" ]; then
  echo "Already tracked: ${VERSION}"
  exit 0
fi

echo "New version: ${VERSION}"

sri_for() {
  local sha512
  sha512=$(awk -v file="$1" '
    /^ *- url: / { url = $3; next }
    /^ +sha512: / { if (url == file) { print $2; exit } }
    /^[^ ]/ { url = "" }
  ' <<<"$MANIFEST")
  if [ -z "$sha512" ]; then
    echo "No sha512 for $1 in $FEED/latest-mac.yml" >&2
    exit 1
  fi
  echo "sha512-${sha512}"
}

file="Capy-${VERSION}-arm64.dmg"
hash=$(sri_for "$file")

mkdir -p versions
jq -n --arg version "$VERSION" --arg url "$FEED/$file" --arg hash "$hash" \
  '{version: $version, platforms: {"aarch64-darwin": {url: $url, hash: $hash}}}' >"versions/${VERSION}.json"
echo "Created versions/${VERSION}.json"
