#!/bin/sh

set -eu

repo_root=$(unset CDPATH; cd "$(dirname "$0")/.." && pwd)
tmp_dir=$(mktemp -d "${TMPDIR:-/tmp}/chap-bump-test.XXXXXX")
trap 'rm -rf "$tmp_dir"' EXIT HUP INT TERM

formula="$tmp_dir/chap.rb"
cp "$repo_root/Formula/chap.rb" "$formula"

sed '/^  url "/d; /^  version "/d; /^  sha256 "/d' "$formula" >"$tmp_dir/before-rest"

sha256=9999999999999999999999999999999999999999999999999999999999999999
CHAP_FORMULA=$formula sh "$repo_root/scripts/bump.sh" 9.9.9 "$sha256"

grep -Fx '  url "https://github.com/luizribeiro/chap-releases/releases/download/v9.9.9/chap-9.9.9-aarch64-apple-darwin.tar.gz"' "$formula" >/dev/null
grep -Fx '  version "9.9.9"' "$formula" >/dev/null
grep -Fx "  sha256 \"$sha256\"" "$formula" >/dev/null

sed '/^  url "/d; /^  version "/d; /^  sha256 "/d' "$formula" >"$tmp_dir/after-rest"
diff -u "$tmp_dir/before-rest" "$tmp_dir/after-rest"

cp "$formula" "$tmp_dir/once.rb"
CHAP_FORMULA=$formula sh "$repo_root/scripts/bump.sh" 9.9.9 "$sha256"
cmp "$tmp_dir/once.rb" "$formula"

sed '/^  sha256 "/d' "$formula" >"$tmp_dir/missing-sha256.rb"
if CHAP_FORMULA="$tmp_dir/missing-sha256.rb" sh "$repo_root/scripts/bump.sh" 9.9.9 "$sha256" 2>"$tmp_dir/error"; then
  echo "error: bump.sh succeeded without a sha256 line" >&2
  exit 1
fi
grep -F 'expected exactly one sha256 line' "$tmp_dir/error" >/dev/null
