#!/bin/bash

# WARNING: Local use only - do not run elsewhere

set -euo pipefail
trap 'echo "Error at line $LINENO" >&2' ERR INT TERM

if [[ $# -eq 1 && ( "$1" = "clean" || "$1" = "clear" ) ]]; then
	rm -rf "$HOME/Test/epub-test/.merged/" \
		"$HOME/Test/epub-test/.merged-splitted/" \
		"$HOME/Test/epub-test/.splitted/"
fi

tcd() {
	[[ -d ~/Test/epub-test/"$1"/ ]] && exit
	rm -rf ~/Test/epub-test/"$1"/
	mkdir -p ~/Test/epub-test/"$1"/
	cd ~/Test/epub-test/"$1"/
}

(
	[[ -d ~/Test/epub-test ]] && exit
	echo ++ Test unit: setup

	mkdir -p ~/Test/epub-test
	rsync -a --delete --exclude .merged --exclude .merged-splitted \
		--exclude .splitted /Volumes/Norway/Backup/Test/epub-test/ \
		~/Test/epub-test
)

(
	tcd .merged
	echo ++ Test unit: merge

	ls ../merged | sed -e 's/.epub//' | while read -r line; do
		epub-merge -q ../original/"$line"*.epub
	done

	cd merged
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
	tcd .merged-splitted
	echo ++ Test unit: merge-splitted

	ls ../merged | sed -e 's/.epub//' | while read -r line; do
		epub-merge -q ../splitted/"$line"*.epub
	done

	cd merged
	for i in *.epub; do
		epub-diff.sh "$i" ../.merged-splitted/"$i"
	done
)

echo "++ All done"
