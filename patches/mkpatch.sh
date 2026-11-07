#!/bin/sh
set -e
here=$(cd "$(dirname "$0")/.." && pwd)
ver=${FIREFOX_VERSION:-153.6.0}
src=$here/external/firefox-$ver
tarball=$here/external/firefox-${ver}esr.source.tar.xz
out=$here/patches/firefox-bleed.patch
marker=$here/external/.firefox-$ver-unpacked
orig=$(mktemp -d)
trap 'rm -rf "$orig"' EXIT

cd "$src"
# unpacked files keep the release dates, anything newer than the unpack marker was touched since
files=$(find . -type f -newer "$marker" ! -path '*/__pycache__/*' ! -name '*.pyc' ! -name '.mozconfig*' \
    ! -path './obj-*' ! -name 'config.status' | sed 's|^\./||' | sort)

# one pass over the tarball for every original, missing ones are new files
for f in $files; do echo "firefox-$ver/$f"; done > "$orig/list"
tar -xJf "$tarball" -C "$orig" -T "$orig/list" 2>/dev/null || true

: > "$out"
for f in $files; do
    if [ -f "$orig/firefox-$ver/$f" ]; then
        diff -u --label "a/$f" --label "b/$f" "$orig/firefox-$ver/$f" "$f" >> "$out" || true
    else
        diff -u --label /dev/null --label "b/$f" /dev/null "$f" >> "$out" || true
    fi
done
echo "$(echo "$files" | grep -c .) files in $out"
