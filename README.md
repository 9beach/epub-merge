# EPUB Tools: epub-merge & epub-meta

This repository provides two **super fast**, lightweight command-line tools written in `bash` for working with EPUB files:

- **[epub-merge](https://github.com/9beach/epub-merge#epub-merge)**: Merges multiple EPUB files into a single volume or extracts a merged EPUB back into its original components.
- **[epub-meta](https://github.com/9beach/epub-merge#epub-meta)**: Reads and edits metadata in an EPUB or standalone OPF file.

Both tools support **EPUB 3** and **EPUB 2**, run on **macOS** and **Linux**, and require only standard POSIX utilities with minimal external libraries (`zip`, `unzip`).

## Installation

```bash
sudo curl -L https://raw.githubusercontent.com/9beach/epub-merge/refs/heads/main/epub-merge -o /usr/local/bin/epub-merge
sudo curl -L https://raw.githubusercontent.com/9beach/epub-merge/refs/heads/main/epub-meta -o /usr/local/bin/epub-meta
sudo chmod a+rx /usr/local/bin/epub-merge /usr/local/bin/epub-meta
```

## Features

### epub-merge

- Merges multiple EPUB files into one volume with a unified table of contents.
- Extracts merged EPUBs back into original files.
- Removes duplicate fonts to reduce file size.
- Automatically detects language and applies cultural volume labels (e.g., Korean: `제 1권`, `제 2권`).
- Customizable titles, labels, and output filenames.
- Minimal dependencies: `zip`, `unzip`, and POSIX tools.

### epub-meta

- Reads, modifies, or removes metadata (e.g., title, author, language) in EPUB or OPF files.
- Supports complex metadata (e.g., CDATA for descriptions).
- Handles multiple authors or subjects (separated by `;`).
- Ensures clean output with MacOS BSD `sed` compatibility (e.g., removes trailing `--`).
- Minimal dependencies: `zip`, `unzip`, and POSIX tools.

## How it works

### epub-merge

**Merging**:

- Creates a volume-based table of contents (TOC) structure:

```text
  Volume 1
    Chapter 1: The Beginning
    Chapter 2: A New Journey
    ...
  Volume 2
    Chapter 4: Challenges Ahead
    Chapter 5: The Turning Point
    ...
```

- Generates book title and filename from common parts of input files (customizable with `-t`).
- Applies language-specific volume labels:
  - Korean: `제 1권`, `제 2권`
  - Chinese: `第1卷`, `第2卷`
  - Japanese: `第1巻`, `第2巻`
  - Spanish: `Volumen 1`, `Volumen 2`
  - French: `Volume 1`, `Volume 2`
  - German: `1. Band`, `2. Band`
  - Russian: `Том 1`, `Том 2`
  - Default: `Volume 1`, `Volume 2`
- Supports custom labels with `-p` (prefix), `-s` (suffix), or `-v` (labels).

**Extracting**:

- Splits EPUBs merged by `epub-merge` into original files.
- Restores original titles and TOC structures.
- Standardizes OPF (`content.opf`), NCX (`toc.ncx`), and font directory (`fonts/`).

## Manuals

### epub-merge

```txt
NAME
     epub-merge -- merge multiple ePUB files into one or extract merged ePUB

SYNOPSIS
     epub-merge [-fOq] [-d directory] [-l lang] [-p prefix] [-s suffix]
                [-t title] [-v labels] file ...
     epub-merge -x file

DESCRIPTION
     The epub-merge utility combines multiple ePUB files into a single volume
     or extracts a previously merged ePUB back into its original components.

     The options are as follows:

     -d directory
             Specify the output directory for generated ePUB files.  The
             default is the current directory.

     -f      Force overwrite of existing files with the same name.

     -l lang
             Specify the language code for the merged ePUB (e.g., ko, en, ja,
             zh, ru).

     -O      Disable natural sorting of input files.

     -p prefix
             Add a prefix to table of contents volume labels.

     -q      Quiet mode.  Suppress progress messages.

     -s suffix
             Add a suffix to table of contents volume labels.
             Set a custom title for the merged ePUB.  This title is also used
             as the output filename.

     -v labels
             Set custom table of contents volume labels for each volume.
             Labels must be separated by semicolons, for example:
             "Love;Peace;Hate".

     -x      Extraction mode.  Split a merged ePUB back into its original
             component files.

EXAMPLES
     Merge three ePUB files with natural sorting (default):

           $ epub-merge love-10.epub love-8.epub love-9.epub
           extracting love-8.epub
           extracting love-9.epub
           extracting love-10.epub
           love.epub: successfully created

     Extract a merged ePUB back into original files:

           $ epub-merge -x love.epub
           love-8.epub: successfully created
           love-9.epub: successfully created
           love-10.epub: successfully created

     Merge files in the order specified (disable natural sorting):

           $ epub-merge -O love-10.epub love-8.epub love-9.epub
           extracting love-10.epub
           extracting love-8.epub
           extracting love-9.epub

     Merge with custom title and filename:

           $ epub-merge -t "Arabian Nights: Tales of 1,001 Nights" a?.epub
           Extracting a1.epub
           Extracting a2.epub
           Extracting a3.epub
           Arabian Nights_ Tales of 1,001 Nights.epub: successfully created
```

### epub-meta

```txt
NAME
     epub-meta -- read and edit metadata information in an ePUB or OPF file

SYNOPSIS
     epub-meta [-t title] [-a author] [-r translator] [-x rights] [-i ISBN]
               [-s subject] [-l language] [-d description] [-p publisher]
               [-u published] [-m modified] {epub-file | opf-file}

DESCRIPTION
     The epub-meta utility allows you to read, modify, or remove standard
     metadata fields within an ePUB container file or a standalone OPF file.

     If no options are specified, epub-meta displays the current metadata
     information from the file.

     To remove a metadata field, pass an empty string ("") as the value.

     The options are as follows:

     -a author
             Set author(s). Multiple authors are allowed, separated by ';'.
             Each author may optionally include a sort name, for example:
             "Tom Waits::Waits, Tom; Lily Allen::Allen, Lily; Beck".

     -d description
             Set description.

     -i ISBN
             Set ISBN.

     -l language
             Set the book's language (e.g., en, ko).

     -m modified
             Set modification date.

     -p publisher
             Set publisher.

     -q      Quiet mode.  Suppress progress messages.

     -r translator
             Set translator(s). Same format as -a.

     -s subject
             Set subject(s). Multiple subjects are allowed, separated by ';'.

     -t title
             Set the book's title.

     -u published
             Set publication date (e.g., "2016-07-31").

     -x rights
             Set rights / copyright info.

     -h
             Show this help message.

EXAMPLES
     Basic usage:

          epub-meta book.epub
          epub-meta -t 'Brave New World' -a 'Aldous Huxley' book.epub
          epub-meta content.opf
          epub-meta -t 'Brave New World' -a 'Aldous Huxley' content.opf

     With CDATA description:

          epub-meta -t "1984" -a "George Orwell" -d '<![CDATA[
          <p>A dystopian novel about totalitarianism.</p>
          <p>Published in 1949.</p>
          ]]>' book.epub
```
