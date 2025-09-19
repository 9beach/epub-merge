#!/bin/bash

# WARNING: Local use only - do not run elsewhere

set -euo pipefail

trap 'echo "Error (epub-merge): at line $LINENO" >&2' ERR INT TERM

cleanup() {
	rm -rf "${TARGET_DIR:?}/.merged/" \
		"${TARGET_DIR:?}/.splitted/" \
		"${TARGET_DIR:?}/.splitted-merged/"
	true
}

trap cleanup EXIT

EPUB_MERGE_DIR="$(realpath "$(dirname "$0")/..")"
SAMPLE_DIR="/Volumes/Norway/Backup/Test/epub-test"
TARGET_DIR="$HOME/Test/epub-test"

epub_diff() {
	"$EPUB_MERGE_DIR/tests/epub-diff.sh" "$@"
}

epub_merge() {
	"$EPUB_MERGE_DIR/epub-merge" "$@"
}

tcd() {
	mkdir -p "$TARGET_DIR/$1"
	cd "$TARGET_DIR/$1"
}

########

echo ++ epub-merge test: setup

cleanup

mkdir -p "$TARGET_DIR"
rsync -a --delete "$SAMPLE_DIR/" "$TARGET_DIR"

########

tcd .merged
echo ++ epub-merge test: merge

# shellcheck disable=SC2012
ls ../merged | sed -e 's/.epub//' | while read -r line; do
	epub_merge -q "../original/$line"*.epub
done

cd ../merged
for i in *.epub; do
	epub_diff "$i" ../.merged/"$i"
done

########

tcd .splitted
echo ++ epub-merge test: split

for i in ../.merged/*; do
	epub_merge -q -x "$i"
done

cd ../splitted
for i in *.epub; do
	epub_diff "$i" ../.splitted/"$i"
done

########

tcd .splitted-merged
echo ++ epub-merge test: merge-splitted

# shellcheck disable=SC2012
ls ../merged | sed -e 's/.epub//' | while read -r line; do
	epub_merge -q ../splitted/"$line"*.epub
done

cd ../merged
for i in *.epub; do
	epub_diff "$i" ../.splitted-merged/"$i"
done

########

echo "++ epub-merge test: All done" || true
