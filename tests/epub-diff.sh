#!/usr/bin/env bash

if [ $# -lt 2 ]; then
	echo "$(basename "$0") epub1 epub2"
	exit 1
fi

set -euo pipefail
trap 'echo "epub-diff error: at line $LINENO" >&2; cleanup' ERR INT TERM

cleanup() {
	[ -n "${TEMP_DIR:-}" ] && rm -rf "$TEMP_DIR"
}

trap cleanup EXIT

grep-v-uuid() {
	local uuid='[0-9a-fA-F]\{8\}-[0-9a-fA-F]\{4\}-[0-9a-fA-F]\{4\}'
	if  [[ -f "$1" ]]; then
		sed 's/^  *//' "$1" \
			| grep -v "$uuid" \
			| grep -v '^$' > "$1.no-uuid"
		mv "$1.no-uuid" "$1"
	fi
}

TEMP_DIR=$(mktemp -d)

mkdir "$TEMP_DIR/1st"
mkdir "$TEMP_DIR/2nd"

unzip -q "$1" -d "$TEMP_DIR/1st"
unzip -q "$2" -d "$TEMP_DIR/2nd"

cd "$TEMP_DIR"

if [[ -z "${EPUB_DIFF_COMPARE_UUID:-}" ]]; then
	grep-v-uuid "1st/content.opf"
	grep-v-uuid "2nd/content.opf"
	grep-v-uuid "1st/toc.ncx"
	grep-v-uuid "2nd/toc.ncx"
fi

diff -r 1st 2nd
