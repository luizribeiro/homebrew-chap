#!/bin/sh

set -eu

response=$(curl -fsSL https://api.github.com/repos/luizribeiro/chap/releases/latest)
version=$(printf '%s\n' "$response" |
  sed -n 's/^[[:space:]]*"tag_name":[[:space:]]*"v\([^"]*\)".*/\1/p' |
  sed -n '1p')

if [ -z "$version" ]; then
  echo "error: latest chap release has no v-prefixed tag_name" >&2
  exit 1
fi

printf '%s\n' "$version"
