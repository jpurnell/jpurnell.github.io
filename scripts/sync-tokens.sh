#!/bin/sh
# Regenerates Assets/css/tokens.css from the DesignTokens package.
# tokens.css is generated and committed; a test fails if it drifts from a fresh emit.
set -eu
cd "$(dirname "$0")/.."
out="$(mktemp -d)"
swift run design-tokens "$out"
cp "$out/tokens.css" Assets/css/tokens.css
rm -rf "$out"
