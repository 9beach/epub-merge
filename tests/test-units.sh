#!/bin/bash

export EPUB_MERGE_TEST=1
export DEBUG="${DEBUG:-}"

EPUB_MERGE_DIR="$(realpath "$(dirname "$0")/..")"

# shellcheck disable=SC1091
source "$EPUB_MERGE_DIR/epub-merge"

# shellcheck disable=SC1091
source "$EPUB_MERGE_DIR/tests/assert.sh"


# Cleanup temp files on exit
cleanup() {
	if [[ -d "${TEMP_DIR:-}" ]]; then
		rm -rf "$TEMP_DIR"
	fi
}

trap cleanup EXIT

TEMP_DIR="$(mktemp -d)"

cd "$TEMP_DIR"

escaped="$(escape_xml_for_sed "<<hello&&")"
assert_eq "$escaped" '\&lt;\&lt;hello\&amp;\&amp;'

escaped="$(escape_xml_for_sed "<<hello&&>>")"
assert_eq "$escaped" '\&lt;\&lt;hello\&amp;\&amp;\&gt;\&gt;'

# path_to_root
assert_eq "$(path_to_root "a.txt")" "."
assert_eq "$(path_to_root "a/b/c.txt")" "../.."
assert_eq "$(path_to_root "b/c.txt")" ".."
assert_eq "$(path_to_root "a/b/c/d.txt")" "../../.."

# path_to_trunk
assert_eq "$(path_to_trunk "a/b")" ""
assert_eq "$(path_to_trunk "a/b/c.txt")" "../"
assert_eq "$(path_to_trunk "a/bb/ccc/dddd/eeee.txt")" "../../../"

# Not ideal, but we assume $1 is always within a trunk and the path is always 
# normalized and relative
assert_eq "$(path_to_trunk "//.//c/b/c.txt")" "//..//../"
assert_eq "$(path_to_trunk "a")" ""
assert_eq "$(path_to_trunk "../b/c.txt")" "../"

# get_epub_version
assert_eq "$(get_version "$EPUB_MERGE_DIR/tests/samples-v3/original/sample1.epub")" 3.0
assert_eq "$(get_version "$EPUB_MERGE_DIR/tests/samples/original/sample1.epub")" 2.0

# xml_get_value_of_element_pattern
xml='<title>Navigation</title><nav epub:type="toc"><li><a href="OEBPS/...'
assert_eq "$(echo "$xml" | split_xml | get_xml_attr "nav ep" "epub:type")" "toc"

mkdir -p "a/b/c/"

{
	echo "src: url(../../../../my-font-dir/KoPubDotumMedium.ttf);"
	echo "src: url(../../../my-rc-dir/KoPubDotumBold.otf);"
} > "a/b/c/root.css"
cp  "a/b/c/root.css"  "a/b/c/trunk.css"

{
	echo "src: url(../../../fonts/KoPubDotumMedium.ttf);"
	echo "src: url(../../../fonts/KoPubDotumBold.otf);"
} > root.expected

{
	echo "src: url(../../fonts/KoPubDotumMedium.ttf);"
	echo "src: url(../../fonts/KoPubDotumBold.otf);"
} > trunk.expected

fix_fontpaths_to_root "a/b/c/root.css"
fix_fontpaths_to_trunk "a/b/c/trunk.css"

diff root.expected a/b/c/root.css
diff trunk.expected a/b/c/trunk.css

assert_summary
