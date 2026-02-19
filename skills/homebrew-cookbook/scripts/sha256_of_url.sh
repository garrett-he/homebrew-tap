#!/usr/bin/env bash
# Download a URL (archive or cask artifact) and print its SHA-256 checksum.
# Usage: sha256_of_url.sh <url>
set -euo pipefail

if [[ $# -ne 1 ]]; then
  echo "Usage: $0 <url>" >&2
  exit 2
fi

url="$1"
tmpdir="$(mktemp -d)"
trap 'rm -rf "$tmpdir"' EXIT

artifact="$tmpdir/artifact"
echo "Downloading $url" >&2
curl --fail --location --retry 3 --silent --show-error --output "$artifact" "$url"

checksum="$(shasum --algorithm 256 "$artifact" | awk '{print $1}')"
printf 'sha256 "%s"\n' "$checksum"
