#!/bin/bash

set -euo pipefail

TEST_DIR="$(realpath "$(dirname "$0")")"

epub_merge() {
	"$TEST_DIR/../epub-merge" "$@"
}

for dir in "$TEST_DIR/samples" "$TEST_DIR/samples-v3"; do
	cd "$dir"
	cd merged
	alias epub_merge=epub-merge
	epub_merge -f ../original/*.epub
	cd ../splitted
	epub_merge -fx ../merged/sample.epub
	cd ../merged-O
	epub_merge -qfO ../original/sample1.epub ../original/sample3.epub \
		../original/sample2.epub
	cd ../merged-lsp
	epub_merge -qfl ko -s "번째 책" ../original/*.epub
done
