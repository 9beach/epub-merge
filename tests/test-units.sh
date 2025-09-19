#!/bin/bash

EPUB_MERGE_DIR="$(realpath "$(dirname "$0")/..")"

export EPUB_MERGE_TEST=1

# shellcheck disable=SC1091
source "$EPUB_MERGE_DIR/epub-merge"

# shellcheck disable=SC1091
source "$EPUB_MERGE_DIR/tests/assert.sh"

assert_eq "$(path_to_trunk "a/b")" ""
assert_eq "$(path_to_root "a/b/c.txt")" "../.."
assert_eq "$(path_to_trunk "a/b/c.txt")" "../"
assert_eq "$(path_to_trunk "a/bb/ccc/dddd/eeee.txt")" "../../../"

# Not ideal, but we assume $1 is always within a trunk and the path is always 
# normalized and relative
assert_eq "$(path_to_trunk "//.//c/b/c.txt")" "//..//../"
assert_eq "$(path_to_trunk "a")" ""
assert_eq "$(path_to_trunk "../b/c.txt")" "../"

assert_summary
