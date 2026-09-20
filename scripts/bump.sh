#!/bin/sh

set -eu

if [ "$#" -lt 1 ] || [ "$#" -gt 2 ]; then
  echo "usage: $0 VERSION [SHA256]" >&2
  exit 1
fi

version=$1
repo_root=$(unset CDPATH; cd "$(dirname "$0")/.." && pwd)
formula=${CHAP_FORMULA:-$repo_root/Formula/chap.rb}
asset="chap-${version}-aarch64-apple-darwin.tar.gz"
url="https://github.com/luizribeiro/chap-releases/releases/download/v${version}/${asset}"

if [ "$#" -eq 2 ]; then
  sha256=$2
else
  checksum_url="${url}.sha256"
  sha256=$(curl -fsSL "$checksum_url" | sed -n '1{s/[[:space:]].*//;p;}')
fi

if ! printf '%s\n' "$sha256" | grep -Eq '^[[:xdigit:]]{64}$'; then
  echo "error: invalid SHA256 for chap ${version}" >&2
  exit 1
fi

for field in url version sha256; do
  count=$(grep -c "^  ${field} \"" "$formula" || :)
  if [ "$count" -ne 1 ]; then
    echo "error: expected exactly one ${field} line in ${formula}" >&2
    exit 1
  fi
done

tmp=$(mktemp "${formula}.tmp.XXXXXX")
trap 'rm -f "$tmp"' EXIT HUP INT TERM

sed \
  -e "s|^  url \".*\"$|  url \"${url}\"|" \
  -e "s|^  version \".*\"$|  version \"${version}\"|" \
  -e "s|^  sha256 \".*\"$|  sha256 \"${sha256}\"|" \
  "$formula" >"$tmp"

chmod 644 "$tmp"
mv "$tmp" "$formula"
trap - EXIT HUP INT TERM
