#!/bin/bash

set -euo pipefail

test_dir="$(realpath "$(dirname "$0")")"

epub_merge() {
	"$test_dir/../epub-merge" "$@"
}

for dir in "$test_dir/samples" "$test_dir/samples-v3"; do
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
	cd ../merged-tv
	epub_merge -fq -v "haha//hoho//heehee" -t "&&<>:/sample" ../original/*.epub
done
