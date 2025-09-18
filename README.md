# epub-merge

[epub-merge](https://github.com/9beach/epub-merge) is a lightweight command-line program written in `bash` that allows merging multiple EPUB files into one volume, or splitting volumes produced by epub-merge.

**Features:**
- Runs on macOS and Linux terminals
- Minimal dependencies - uses only built-in shell commands
- Requires only basic utilities: `zip`, `unzip`, and standard POSIX tools
- No external libraries or complex installations needed

## How it works

**Merging:**
- Creates a new volume-based table of contents structure at the top level
- Automatically generates book title and filename from common parts of input files (can be customized with `-n` option)
- Removes duplicate fonts to reduce overall file size
- Detects language from EPUB metadata or content analysis, then applies appropriate cultural conventions:
  - Korean: `제 1권`, `제 2권`
  - Chinese: `第1卷`, `第2卷`
  - Japanese: `第1巻`, `第2巻`
  - Spanish: `Volumen 1`, `Volumen 2`
  - French: `Volume 1`, `Volume 2`
  - German: `1. Band`, `2. Band`
  - Russian: `Том 1`, `Том 2`
  - Default: `Volume 1`, `Volume 2`
- Volume labels can be customized with `-p` (prefix) and `-s` (suffix) options
- Merged TOC structure:
  ```
  Volume 1
    Chapter 1: The Beginning
    Chapter 2: A New Journey
    Chapter 3: The Discovery
    ....
  Volume 2
    Chapter 4: Challenges Ahead
    Chapter 5: The Turning Point
    Chapter 6: Resolution
    ....
  Volume n
  ```

**Extracting:**
- Only EPUBs merged with epub-merge can be split back
- Perfectly restores original book titles and table of contents
- Note: Internal OPF and NCX files are standardized to `content.opf` and `toc.ncx`
- Font directory is standardized to `fonts/`

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
          extracting love-8.epub
          extracting love-9.epub
          extracting love-10.epub
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
