#!/bin/bash

set -euo pipefail

export DEBUG="${DEBUG:-}"

trap 'echo "Error (epub-merge): at line $LINENO" >&2' ERR INT TERM

cleanup() {
	[[ -n "$TEMP_DIR" ]] && rm -fr "$TEMP_DIR" || true
}

trap cleanup EXIT

# export DEBUG=1
TARGET_DIR=""
TEMP_DIR=""

EPUB_MERGE_DIR="$(realpath "$(dirname "$0")/..")"

SAMPLE_DIR="${SAMPLE_DIR:-"$EPUB_MERGE_DIR/tests/samples"}"
TEMP_DIR="$(mktemp -d)"
TARGET_DIR="$TEMP_DIR"

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

mkdir -p "$TARGET_DIR"
rsync -a --delete "$SAMPLE_DIR/" "$TARGET_DIR"

########

tcd .merged
echo ++ epub-merge test: merge original

# shellcheck disable=SC2012
epub_merge -q ../original/*.epub

epub_diff "sample.epub" ../merged/sample.epub

########

tcd .splitted-merged
echo ++ epub-merge test: merge splitted

# shellcheck disable=SC2012
epub_merge -q ../splitted/*.epub

mv sample.epub 2nd-merge.epub
epub_merge -xfq 2nd-merge.epub

for i in sample?.epub; do
	epub_diff "$i" ../splitted/"$i"
done

epub_merge -q sample?.epub
mv sample.epub 3rd-merge.epub

epub_diff 2nd-merge.epub 3rd-merge.epub
diff 2nd-merge.epub 3rd-merge.epub > /dev/null && exit

epub_merge -xfq 3rd-merge.epub

for i in sample?.epub; do
	epub_diff "$i" ../splitted/"$i"
done

########

tcd .splitted
echo ++ epub-merge test: -x option

epub_merge -q -x ../merged/sample.epub

cd ../splitted
for i in *.epub; do
	epub_diff "$i" ../.splitted/"$i"
done

########

tcd .merged-O
echo ++ epub-merge test: -O option

epub_merge -qO ../original/sample1.epub ../original/sample3.epub \
	../original/sample2.epub

epub_diff sample.epub ../merged-O/sample.epub

epub_merge -qx sample.epub

cd ../splitted
for i in *.epub; do
	epub_diff "$i" ../.merged-O/"$i"
done

########

tcd .merged-lsp
echo ++ epub-merge test: -l, -s, -p options

epub_merge -ql ko -s "번째 책" ../original/*.epub

epub_diff sample.epub ../merged-lsp/sample.epub

epub_merge -qx sample.epub

cd ../splitted
for i in *.epub; do
	epub_diff "$i" ../.merged-lsp/"$i"
done

########

tcd .force-write
echo "++ epub-merge test: -f option"

epub_merge -q ../original/*.epub
cp sample.epub copied
epub_merge -q ../original/*.epub 2> /dev/null && false || true

# If merged again, UUID changed, then epub_diff returns 0, diff returns 1
diff -q sample.epub copied
epub_merge -qf ../original/*.epub
diff -q sample.epub copied > /dev/null 2>&1 && false || true
epub_diff sample.epub copied

########

tcd .target-dir
echo "++ epub-merge test: -d option"

cd ..
epub_merge -qd .target-dir original/*.epub

epub_diff merged/sample.epub .target-dir/sample.epub

########

tcd .title
echo "++ epub-merge test: -t, -n option"

epub_merge -q -n "test hahaha" -t "sample" ../original/*.epub
epub_diff ../merged/sample.epub "test hahaha.epub"

########

tcd .name
echo "++ epub-merge test: -n option"

epub_merge -q -n "test hahaha" ../original/*.epub
[[ -f "test hahaha.epub" ]]

########

tcd .dir
echo "++ epub-merge test: -d option"

cd ..
epub_merge -qd '.dir' original/*.epub

epub_diff merged/sample.epub .dir/sample.epub

########

echo "++ epub-merge test: All done" || true
