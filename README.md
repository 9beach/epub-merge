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
- Handles multiple authors or subjects (separated by `//`).
- Minimal dependencies: `zip`, `unzip`, and POSIX tools.

## How it works

## How it works

### epub-merge

**Merging EPUB Files**:

- Combines multiple EPUB files into a single EPUB with a unified table of contents (TOC) organized by volume.
- Automatically generates a book title based on common parts of input filenames (e.g., `love-1.epub`, `love-2.epub` → `love.epub`) unless overridden with `-t`.
- Creates a volume-based TOC structure, grouping chapters from each input EPUB under volume labels:

  ```
  Volume 1
    Chapter 1: The Beginning
    Chapter 2: A New Journey
  Volume 2
    Chapter 4: Challenges Ahead
    Chapter 5: The Turning Point
  ```

- Applies language-specific volume labels based on the `-l` option (e.g., `-l ko` for Korean produces `제 1권`, `제 2권`).
- Removes duplicate fonts across input EPUBs to optimize file size.
- Supports natural sorting of input files (e.g., `love-8.epub`, `love-9.epub`, `love-10.epub` are sorted correctly) unless disabled with `-O`.
- Allows customization of volume labels with `-p` (prefix), `-s` (suffix), or `-v` (custom labels, e.g., `-v "Part 1//Part 2//Part 3"`).
- Outputs the merged EPUB to the current directory or a specified directory with `-d`.

**Extracting EPUB Files**:

- Splits a previously merged EPUB back into its original component EPUBs using the `-x` option.
- Restores each original EPUB’s title, TOC, and structure, including standardized OPF (`content.opf`), NCX (`toc.ncx`), and font directory (`fonts/`).
- Preserves all original metadata and content from the source EPUBs.

**Examples in Action**:

- **Merge with default settings**: Combine three EPUBs with natural sorting:

  ```
  epub-merge love-10.epub love-8.epub love-9.epub
  ```

  Output: `love.epub` with TOC:

  ```
  Volume 1
    Chapter 1
    Chapter 2
  Volume 2
    Chapter 3
    Chapter 4
  Volume 3
    Chapter 5
    Chapter 6
  ```

  Result: `love.epub: successfully created`.
- **Merge with custom title**: Specify a custom title and output filename:

  ```
  epub-merge -t "Arabian Nights: Tales of 1,001 Nights" a1.epub a2.epub
  ```

  Output: `Arabian Nights_ Tales of 1,001 Nights.epub` with TOC labeled as `Volume 1`, `Volume 2`.
- **Merge with Korean labels**: Use Korean language for volume labels:

  ```
  epub-merge -l ko novel-1.epub novel-2.epub
  ```

  Output: `novel.epub` with TOC:

  ```
  제 1권
    Chapter 1
    Chapter 2
  제 2권
    Chapter 3
    Chapter 4
  ```

- **Custom volume labels**: Define specific volume labels:

  ```
  epub-merge -v "Love//Peace//Hate" story-1.epub story-2.epub story-3.epub
  ```

  Output: `story.epub` with TOC:

  ```
  Love
    Chapter 1
    Chapter 2
  Peace
    Chapter 3
    Chapter 4
  Hate
    Chapter 5
  ```

- **Extract merged EPUB**: Split a merged EPUB back into originals:

  ```
  epub-merge -x love.epub
  ```

  Output: Restores `love-8.epub`, `love-9.epub`, `love-10.epub` with their original TOCs and metadata.
- **Merge with prefix and suffix**: Add custom prefix and suffix to volume labels:

  ```
  epub-merge -p "Book " -s " Edition" part1.epub part2.epub
  ```

  Output: `part.epub` with TOC:

  ```
  Book 1 Edition
    Chapter 1
  Book 2 Edition
    Chapter 2
  ```

### epub-meta

**Reading Metadata**:

- Displays standard metadata fields (e.g., title, author, language, ISBN) from an EPUB or standalone OPF file when no options are provided.
- Outputs metadata in a clear, human-readable format for easy inspection.

**Editing Metadata**:

- Modifies specific metadata fields using command-line options (e.g., `-t` for title, `-a` for author).
- Supports multiple values for fields like authors or subjects, separated by `//` (e.g., `-a "Author1//Author2"`).
- Handles complex metadata like descriptions with CDATA for rich text formatting.
- Updates metadata directly within the EPUB or OPF file while preserving other content.

**Removing Metadata**:

- Removes specific metadata fields by passing an empty string (`""`) as the value (e.g., `-t ""` to remove the title).

**Examples in Action**:

- **Read metadata**: Running `epub-meta book.epub` might output:

  ```
  Title: Brave New World
  Author: Aldous Huxley
  Language: en
  ISBN: 978-3-16-148410-0
  Description: A dystopian novel exploring a futuristic society.
  Publisher: Chatto & Windus
  Publication Date: 1932-01-01
  ```

- **Edit metadata**: To update the title and author:

  ```
  epub-meta -t "Brave New World Revised" -a "Aldous Huxley//John Doe" book.epub
  ```

  This updates the EPUB’s title to "Brave New World Revised" and sets two authors, preserving other metadata.
- **Remove metadata**: To remove the ISBN:

  ```
  epub-meta -i "" book.epub
  ```

  This clears the ISBN field from the EPUB’s metadata.
- **Add complex description**: To add a multi-line description with CDATA:

  ```
  epub-meta -d '<![CDATA[
  <p>A dystopian novel about totalitarianism.</p>
  <p>Published in 1949.</p>]]>' -t "1984" book.epub
  ```

  This sets a formatted description and updates the title to "1984".
- **Multiple authors with sort names**: To set multiple authors with sorting metadata:

  ```
  epub-meta -a "Tom Waits--Waits, Tom//Lily Allen--Allen, Lily" book.epub
  ```

  This assigns two authors with their respective sort names for proper cataloging.

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
             "Love//Peace//Hate".

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
             Set author(s). Multiple authors are allowed, separated by "//".
             Each author may optionally include a sort name, for example:
             "Tom Waits--Waits, Tom//Lily Allen--Allen, Lily//Beck".

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
             Set subject(s). Multiple subjects are allowed, separated by ''.

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
