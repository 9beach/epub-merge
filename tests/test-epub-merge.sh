#!/bin/bash

set -euo pipefail

export DEBUG="${DEBUG:-}"
epub_merge_dir="$(realpath "$(dirname "$0")/..")"

trap 'echo "Error (epub-merge): at line $LINENO" >&2' ERR INT TERM

cleanup() {
	[[ -n "$temp_dir" ]] && rm -fr "$temp_dir" || true
}

trap cleanup EXIT

epub_diff() {
	echo "│   ↳ ""$(echo "$1" | sed "s#$epub_merge_dir/tests/##") ── $2"
	"$epub_merge_dir/tests/epub-diff.sh" "$@"
}

epub_merge() {
	"$epub_merge_dir/epub-merge" "$@"
}

tcd() {
	rm -rf "$temp_dir/$1"
	mkdir -p "$temp_dir/$1"
	cd "$temp_dir/$1"
}

temp_dir="$(mktemp -d)"
cd "$temp_dir"

for dir in "samples" "samples-v3"; do
	sample_dir="$epub_merge_dir/tests/$dir"

	echo ".   epub-merge test: $dir"

	########

	echo ├── epub-merge test: setup

	########

	tcd .merged
	echo ├── epub-merge test: merge original

	# shellcheck disable=SC2012
	epub_merge -q "$sample_dir"/original/*.epub

	epub_diff "$sample_dir"/merged/sample.epub "sample.epub" 

	########

	tcd .splitted-merged
	echo ├── epub-merge test: merge splitted

	# shellcheck disable=SC2012
	epub_merge -q "$sample_dir"/splitted/*.epub

	mv sample.epub 2nd-merge.epub
	epub_merge -xfq 2nd-merge.epub

	for i in sample?.epub; do
		epub_diff "$sample_dir"/splitted/"$i" "$i" 
	done

	epub_merge -q sample?.epub
	mv sample.epub 3rd-merge.epub

	epub_diff 2nd-merge.epub 3rd-merge.epub
	diff 2nd-merge.epub 3rd-merge.epub > /dev/null && exit

	epub_merge -xfq 3rd-merge.epub

	for i in sample?.epub; do
		epub_diff "$sample_dir"/splitted/"$i" "$i" 
	done

	########

	tcd .splitted
	echo ├── epub-merge test: -x option

	epub_merge -q -x "$sample_dir"/merged/sample.epub

	for i in sample?.epub; do
		epub_diff "$sample_dir/splitted/$i" "$i"
	done

	########

	tcd .merged-O
	echo ├── epub-merge test: -O option

	epub_merge -qO "$sample_dir"/original/sample1.epub \
		"$sample_dir"/original/sample3.epub \
		"$sample_dir"/original/sample2.epub

	epub_diff "$sample_dir"/merged-O/sample.epub sample.epub 

	epub_merge -qx sample.epub

	for i in sample?.epub; do
		epub_diff "$sample_dir/splitted/$i" "$i" 
	done

	########

	tcd .merged-lsp
	echo ├── epub-merge test: -l, -s, -p options

	epub_merge -ql ko -s "번째 책" "$sample_dir"/original/*.epub

	epub_diff "$sample_dir"/merged-lsp/sample.epub sample.epub

	epub_merge -qx sample.epub

	for i in sample?.epub; do
		epub_diff "$sample_dir/splitted/$i" "$i" 
	done

	########

	tcd .force-write
	echo "├── epub-merge test: -f option"

	epub_merge -q "$sample_dir"/original/*.epub
	cp sample.epub copied
	epub_merge -q "$sample_dir"/original/*.epub \
		2> /dev/null && false || true

	# If merged again, UUID changed, then epub_diff -> 0, diff -> 1
	diff -q sample.epub copied
	epub_merge -qf "$sample_dir"/original/*.epub
	diff -q sample.epub copied > /dev/null 2>&1 && false || true
	epub_diff sample.epub copied

	########

	tcd .target-dir
	echo "├── epub-merge test: -d option"

	cd ..
	epub_merge -qd .target-dir "$sample_dir/original"/*.epub

	epub_diff "$sample_dir/merged/sample.epub" .target-dir/sample.epub 

	########

	tcd .title
	echo "├── epub-merge test: -t, -v option"

	epub_merge -q -v "haha//hoho//heehee" -t "&&<>:/sample" "$sample_dir"/original/*.epub
	epub_diff "$sample_dir"/merged-tv/sample.epub "&&____sample.epub" 

	########

	tcd .name
	echo "├── epub-merge test: -n option"

	epub_merge -q -n "test hahaha" "$sample_dir"/original/*.epub
	[[ -f "test hahaha.epub" ]]

	########

	tcd .dir
	echo "├── epub-merge test: -d option"

	cd ..
	epub_merge -qd '.dir' "$sample_dir/original"/*.epub

	epub_diff "$sample_dir/merged/sample.epub" .dir/sample.epub 

	########

	echo "└── all done"
done

sample_dir="$epub_merge_dir/tests/samples"

times=10

time ( for i in $(seq 1 $times); do epub_merge -f "$sample_dir"/original/* \
	2> /dev/null; done )

echo
echo "$times merge completed"

time ( for i in $(seq 1 $times); do epub_merge \
	-fx "$sample_dir"/merged/sample.epub 2> /dev/null; done )

echo
echo "$times extract completed"
