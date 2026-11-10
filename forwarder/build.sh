#!/bin/sh
# Packs the forwarder for a code-only Function: the managed Python runtime
# expects function/func.py at the archive root and ships the Fn SDK itself.
set -eu
cd "$(dirname "$0")/.."
dir=$(mktemp -d)
mkdir "$dir/function"
cp forwarder/func.py "$dir/function/"
rm -f forwarder.zip
(cd "$dir" && zip -qX "$OLDPWD/forwarder.zip" function/func.py)
rm -rf "$dir"
