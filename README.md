# epub-merge

[epub-merge](https://github.com/9beach/epub-merge) is a lightweight command-line program written in `bash` that allows merging multiple EPUB files into one volume, or splitting volumes produced by epub-merge.

**Features:**
- Runs on macOS and Linux terminals
- Minimal dependencies - uses only built-in shell commands
- Requires only basic utilities: `zip`, `unzip`, and standard POSIX tools
- No external libraries or complex installations needed

## Installation

```bash
sudo curl -L https://raw.githubusercontent.com/9beach/epub-merge/main/epub-merge -o /usr/local/bin/epub-merge
sudo chmod a+rx /usr/local/bin/epub-merge
```

## Usage

```
NAME
     epub-merge - combines multiple EPUB files into a single volume, or 
     extracts merged EPUB files

SYNOPSIS
     epub-merge [OPTIONS] epub1 epub2 [epub3 ...]
     epub-merge -x merged-epub.epub

OPTIONS
     -n name        Custom output filename (without extension)
     -l lang        Language code (ko, en, ja, zh, ru, etc.)
     -p prefix      Prefix for TOC volume labels
     -s suffix      Suffix for TOC volume labels
     -S             Disable automatic suffix assignment for TOC volumes
     -O             Disable natural sorting of input files
     -q             Suppress progress messages
     -x             Extract mode: split merged EPUB back to original files

EXAMPLES
     epub-merge love-10.epub love-8.epub love-9.epub
          extracting love-10.epub
          extracting love-8.epub
          extracting love-9.epub
          love.epub: successfully created

     epub-merge -x love.epub
          love-8.epub: successfully created
          love-9.epub: successfully created
          love-10.epub: successfully created

     epub-merge -O love-10.epub love-8.epub love-9.epub
          extracting love-10.epub
          extracting love-8.epub
          extracting love-9.epub
          love.epub: successfully created

     epub-merge -n "One Thousand and One Nights" ../1001-nights*.epub
          ...
          One Thousand and One Nights.epub: successfully created
```
