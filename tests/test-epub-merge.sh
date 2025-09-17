#!/bin/bash

# WARNING: Local environment only - do not run elsewhere

set -euo pipefail
trap 'echo "Error at line $LINENO" >&2' ERR INT TERM

tcd() {
	rm -rf ~/Test/epub-test/"$1"/
	mkdir -p ~/Test/epub-test/"$1"/
	cd ~/Test/epub-test/"$1"/
}

echo ++ test unit: setup

mkdir -p ~/Test/epub-test
rsync -a --delete /Volumes/Norway/Backup/Test/epub-test/ ~/Test/epub-test

echo ++ test unit: merge

tcd .merged

ls ../merged | sed -e 's/.epub//' | while read -r line; do
	epub-merge -q ../original/"$line"*.epub
done

for i in *.epub; do
	epub-diff.sh "$i" ../merged/"$i"
done

echo ++ test unit: split

tcd .splitted

for i in ../merged/*; do
	epub-merge -q -x "$i"
done

for i in *.epub; do
	epub-diff.sh "$i" ../splitted/"$i"
done

echo ++ test unit: merge-splitted

tcd .merged-splitted

ls ../merged | sed -e 's/.epub//' | while read -r line; do
	epub-merge -q ../splitted/"$line"*.epub
done

echo All done
