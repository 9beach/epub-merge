#!/bin/bash

set -euo pipefail
trap 'echo "Error at line $LINENO" >&2' ERR INT TERM

readonly AUTHOR_LOCAL_ENV=${AUTHOR_LOCAL_ENV:-0}
TARGET_DIR=""

cleanup() {
        if [[ "$AUTHOR_LOCAL_ENV" == 0 && -n "$TARGET_DIR" ]]; then
                rm -fr "$TARGET_DIR"
        fi
}

trap cleanup EXIT

if [[ $AUTHOR_LOCAL_ENV == 1 ]]; then
	# WARNING: Local use only - do not run elsewhere
	SOURCE_DIR="/Volumes/Norway/Backup/Test/epub-test"
	TARGET_DIR="$HOME/Test/epub-test"
else
	SOURCE_DIR="$(dirname "$0")/samples"
	TARGET_DIR="$(mktemp -d)"
fi

epub_diff() {
	local source_dir="${SOURCE_DIR:-/default/path}"
	"${source_dir}/../epub-diff.sh" "$@"
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
		echo $ARG
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
		--exclude .splitted "$SOURCE_DIR/" "$TARGET_DIR"
)

(
	tcd .merged
	echo ++ Test unit: merge

	ls ../merged | sed -e 's/.epub//' | while read -r line; do
		epub-merge -q ../original/"$line"*.epub
	done

	cd ../merged
	for i in *.epub; do
		epub-diff.sh "$i" ../.merged/"$i"
	done
)

(
	tcd .splitted
	echo ++ Test unit: split

	for i in ../.merged/*; do
		epub-merge -q -x "$i"
	done

	cd ../splitted
	for i in *.epub; do
		epub-diff.sh "$i" ../.splitted/"$i"
	done
)

(
	tcd .splitted-merged
	echo ++ Test unit: merge-splitted

	ls ../merged | sed -e 's/.epub//' | while read -r line; do
		epub-merge -q ../splitted/"$line"*.epub
	done

	cd ../merged
	for i in *.epub; do
		epub-diff.sh "$i" ../.splitted-merged/"$i"
	done
)

echo "++ All done"
