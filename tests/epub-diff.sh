#!/usr/bin/env bash

if [ $# -lt 2 ]; then
	echo "$(basename "$0") epub1 epub2"
	exit 1
fi

set -euo pipefail
trap 'echo "epub-diff error: at line $LINENO" >&2; cleanup' ERR INT TERM

cleanup() {
	[ -n "${temp_dir:-}" ] && rm -rf "$temp_dir"
}

trap cleanup EXIT

if [[ "$OSTYPE" == "darwin"* ]]; then
	sed_i() {
		sed -i '' "$@"
	}
else
	sed_i() {
		sed -i "$@"
	}
fi

readonly UUID='[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}'

filter_uuid() {
	if  [[ -f "$1" ]]; then
		grep -Ev "($UUID|^[[:space:]]*$)" "$1" \
			> "$1.no-uuid" || true
		mv "$1.no-uuid" "$1"
	fi
}

temp_dir=$(mktemp -d)
readonly temp_dir

mkdir "$temp_dir/1st"
mkdir "$temp_dir/2nd"

unzip -q "$1" -d "$temp_dir/1st"
unzip -q "$2" -d "$temp_dir/2nd"

cd "$temp_dir"

if [[ -z "${EPUB_DIFF_COMPARE_UUID:-}" ]]; then
	filter_uuid "1st/content.opf"
	filter_uuid "2nd/content.opf"
	filter_uuid "1st/toc.ncx"
	filter_uuid "2nd/toc.ncx"
fi

diff -r 1st 2nd
