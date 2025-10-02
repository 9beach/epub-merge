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

if [[ "$OSTYPE" == "darwin"* ]]; then
	sed_i() {
		sed -i '' "$@"
	}
else
	sed_i() {
		sed -i "$@"
	}
fi

XML_FORMATTER=""

if command -v xmllint &> /dev/null; then
	XML_FORMATTER="xmllint"
elif command -v python3 &> /dev/null; then
	XML_FORMATTER="python3"
else
	XML_FORMATTER="cat"
	log "The XML formatter is not installed, which may cause errors during the merge process. Please install xmllint."
fi

# Format XML/HTML file
if [[ "$XML_FORMATTER" == "xmllint" ]]; then
	format_xml() {
		local file="$1"
		local temp_xml="$TEMP_DIR/.xml.XXXXX"
		xmllint --recover --format --noblanks "$file" \
			> "${temp_xml}" 2>/dev/null \
			&& mv "${temp_xml}" "$file"
		}
elif [[ "$XML_FORMATTER" == "python3" ]]; then
	format_xml() {
		debug_func "$@"
		local file="$1"
		local temp_xml="$TEMP_DIR/.xml.XXXXX"
		python3 -c "import xml.dom.minidom as x,sys; print(x.parseString(open(sys.argv[1]).read()).toprettyxml(indent='    '))" "$file" 2>/dev/null \
			| grep -v "^ *$" \
			> "${temp_xml}" \
			&& mv "${temp_xml}" "$file"
		}
else
	format_xml() {
		debug_func "$@"
		log "XML formatter not available"
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

TEMP_DIR=$(mktemp -d)
readonly TEMP_DIR

mkdir "$TEMP_DIR/1st"
mkdir "$TEMP_DIR/2nd"

unzip -q "$1" -d "$TEMP_DIR/1st"
unzip -q "$2" -d "$TEMP_DIR/2nd"

cd "$TEMP_DIR"

find . -type f \( -iname "*.opf" -o -iname "*.ncx"  -o -iname "nav.xhtml" \) -print0 | while IFS= read -r -d '' file; do
	format_xml "$file"
done

find . -type f \( -iname "*.css" \) -print0 | while IFS= read -r -d '' i; do
	grep -v 'url(eOpenBooks.ttf)' "$i" > "$i.tmp" && mv "$i.tmp" "$i"
done

if [[ -z "${EPUB_DIFF_COMPARE_UUID:-}" ]]; then
	filter_uuid "1st/content.opf"
	filter_uuid "2nd/content.opf"
	filter_uuid "1st/toc.ncx"
	filter_uuid "2nd/toc.ncx"
fi

rm "1st/META-INF/container.xml"
rmdir "1st/fonts" 2> /dev/null || true
rm "2nd/META-INF/container.xml"
rmdir "2nd/fonts" 2> /dev/null|| true

diff -r 1st 2nd
