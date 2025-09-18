#!/bin/bash

set -euo pipefail
trap 'echo "Error (epub-merge): at line $LINENO" >&2' ERR INT TERM

readonly AUTHOR_LOCAL_ENV=${AUTHOR_LOCAL_ENV:-0}
TARGET_DIR=""
TEMP_DIR=""

cleanup() {
	[[ -n "$TEMP_DIR" ]] && rm -fr "$TEMP_DIR"
	true
}

trap cleanup EXIT

EPUB_MERGE_DIR="$(realpath "$(dirname "$0")/..")"

if [[ $AUTHOR_LOCAL_ENV == 1 ]]; then
	# WARNING: Local use only - do not run elsewhere
	SAMPLE_DIR="/Volumes/Norway/Backup/Test/epub-test"
	TARGET_DIR="$HOME/Test/epub-test"
else
	SAMPLE_DIR="$(realpath "$(dirname "$0")/samples")"
	TEMP_DIR="$(mktemp -d)"
	TARGET_DIR="$TEMP_DIR"
fi

epub_diff() {
	"$EPUB_MERGE_DIR/tests/epub-diff.sh" "$@"
}

epub_merge() {
	"$EPUB_MERGE_DIR/epub-merge" "$@"
}

ARG=""

if [[ $# -eq 0 ]]; then
	ARG=clean
elif [[ $# -eq 1 ]]; then
	ARG="$1"
else
	echo "Bad argument" >&2
	exit 1
fi

case "$ARG" in
	clean)
		rm -rf "$TARGET_DIR/.merged/" \
			"$TARGET_DIR/.splitted/" \
			"$TARGET_DIR/.splitted-merged/"
		;;
	merge)
		rm -rf "$TARGET_DIR/.merge/"
		;;
	split)
		rm -rf "$TARGET_DIR/.splitted/"
		;;
	merge-splitted)
		rm -rf "$TARGET_DIR/.splitted-merged/"
		;;
	*)
		echo "Bad argument" >&2
		exit 1
		;;
esac

if [[ $# -eq 1 && ( "$1" = "clean" || "$1" = "clear" ) ]]; then
	rm -rf "$TARGET_DIR/.merged/" \
		"$TARGET_DIR/.splitted-merged/" \
		"$TARGET_DIR/.splitted/"
fi

tcd() {
	[[ -d "$TARGET_DIR/$1" ]] && exit
	rm -rf "$TARGET_DIR/$1"
	mkdir -p "$TARGET_DIR/$1"
	cd "$TARGET_DIR/$1"
}

(
	[[ -d "$TARGET_DIR/merged" ]] && exit
	echo ++ Test unit: setup

	mkdir -p "$TARGET_DIR"
	rsync -a --delete --exclude .merged --exclude .splitted-merged \
		--exclude .splitted "$SAMPLE_DIR/" "$TARGET_DIR"
)

(
	tcd .merged
	echo ++ Test unit: merge

	ls ../merged | sed -e 's/.epub//' | while read -r line; do
		epub_merge -q "../original/$line"*.epub
	done

	cd ../merged
	for i in *.epub; do
		epub_diff "$i" ../.merged/"$i"
	done
)

(
	tcd .splitted
	echo ++ Test unit: split

	for i in ../.merged/*; do
		epub_merge -q -x "$i"
	done

	cd ../splitted
	for i in *.epub; do
		epub_diff "$i" ../.splitted/"$i"
	done
)

(
	tcd .splitted-merged
	echo ++ Test unit: merge-splitted

	ls ../merged | sed -e 's/.epub//' | while read -r line; do
		epub_merge -q ../splitted/"$line"*.epub
	done

	cd ../merged
	for i in *.epub; do
		epub-diff.sh "$i" ../.splitted-merged/"$i"
	done
)

echo "++ All done" || true
