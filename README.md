# EPUB Tools: epub-merge & epub-meta

This repository provides two **super fast**, lightweight command-line tools written in `bash` for working with EPUB files:

- **[epub-merge](#epub-merge)** — Merge multiple EPUB files into a single volume or extract a merged EPUB back into its original components.
- **[epub-meta](#epub-meta)** — Read, edit, and repair metadata in an EPUB or standalone OPF file.

Both tools support **EPUB 3** and **EPUB 2**, run on **macOS** and **Linux**, and require only standard POSIX utilities with minimal external libraries (`zip`, `unzip`).

## Installation

```bash
sudo curl -L https://raw.githubusercontent.com/9beach/epub-merge/refs/heads/main/epub-merge -o /usr/local/bin/epub-merge
sudo curl -L https://raw.githubusercontent.com/9beach/epub-merge/refs/heads/main/epub-meta -o /usr/local/bin/epub-meta
sudo chmod a+rx /usr/local/bin/epub-merge /usr/local/bin/epub-meta
````

## Features

### epub-merge

- Merge multiple EPUB files into one volume with a unified table of contents (TOC).
- Extract merged EPUBs back into their original component files.
- Remove duplicate fonts to reduce file size.
- Automatically detect language and apply localized volume labels (e.g., Korean: `제 1권`, `제 2권`).
- Customize titles, labels, and output filenames.
- Minimal dependencies: `zip`, `unzip`, and standard POSIX tools.

### epub-meta

- Read, modify, or remove metadata in EPUB or OPF files.
- Edit basic fields such as **title**, **author**, **language**, **publisher**, **publication date**, and **ISBN**.
- Support **multiple authors** or **subjects** separated by `//`.
- Handle **complex metadata** such as descriptions wrapped in CDATA blocks.
- Manage cover images:

  - `-c FILE` — Add or set a new cover image.
  - `-C FILE` — Replace an existing cover image.
  - `-S PATH` — Extract the current cover image (extension auto-added).
  - `-f` — Automatically fix invalid cover configurations.
- Minimal dependencies: `zip`, `unzip`, and standard POSIX tools.

## How it works

### epub-merge

#### Merging EPUB Files

- Combines multiple EPUBs into one with a unified TOC organized by volume.
- Automatically generates a title based on input filenames unless overridden with `-t`.
- Applies language-specific or custom volume labels with `-l`, `-p`, `-s`, or `-v`.
- Removes duplicate fonts to minimize file size.
- Supports natural sorting of filenames (e.g., `love-8.epub`, `love-9.epub`, `love-10.epub`).
- Outputs the result to the current or specified directory (`-d`).

#### Extracting EPUB Files

- Splits a previously merged EPUB into its original components using `-x`.
- Restores metadata, TOC, and structure for each extracted EPUB.

#### Examples

```bash
epub-merge love-10.epub love-8.epub love-9.epub
epub-merge -t "Arabian Nights: Tales of 1,001 Nights" a1.epub a2.epub
epub-merge -l ko novel-1.epub novel-2.epub
epub-merge -v "Love//Peace//Hate" story-1.epub story-2.epub story-3.epub
epub-merge -p "Book " -s " Edition" part1.epub part2.epub
epub-merge -x love.epub
```

### epub-meta

#### Reading Metadata

Run without options to display current metadata:

```bash
epub-meta book.epub
```

Output example:

```
Title: Brave New World
Author: Aldous Huxley
Language: en
ISBN: 978-3-16-148410-0
Publisher: Chatto & Windus
Publication Date: 1932-01-01
```

#### Editing Basic Metadata

Set or update common metadata fields:

```bash
# Set title and author
epub-meta -t "Brave New World Revised" -a "Aldous Huxley" book.epub

# Multiple authors or translators
epub-meta -a "Tom Waits--Waits, Tom//Lily Allen--Allen, Lily" book.epub
epub-meta -r "Deborah Smith//John Doe" book.epub

# Language, publisher, and dates
epub-meta -l ko -p "문학동네" -u "2024-08-15" book.epub

# ISBN and subject
epub-meta -i "978-89-546-1234-5" -s "Fiction//Classic" book.epub
```

#### Adding Complex Descriptions

Use CDATA for formatted or multi-line descriptions:

```bash
epub-meta -d '<![CDATA[
<p>A dystopian novel about totalitarianism.</p>
<p>Published in 1949.</p>]]>' book.epub
```

#### Managing Cover Images

```bash
# Add a new cover image
epub-meta -c cover.jpg book.epub

# Replace an existing cover
epub-meta -C new-cover.png book.epub

# Extract current cover to a file (extension auto-added)
epub-meta -S ./cover-out book.epub

# Automatically fix invalid cover configurations
epub-meta -f book.epub
```

#### Removing Metadata

Remove any field by passing an empty string:

```bash
epub-meta -t "" -a "" -i "" book.epub
```

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
             Specify the output directory for generated ePUB files. The
             default is the current directory.

     -f      Force overwrite of existing files with the same name.

     -l lang
             Specify the language code for the merged ePUB (e.g., ko, en, ja,
             zh, ru).

     -O      Disable natural sorting of input files.

     -p prefix
             Add a prefix to table of contents volume labels.

     -q      Quiet mode. Suppress progress messages.

     -s suffix
             Add a suffix to table of contents volume labels.
             Set a custom title for the merged ePUB. This title is also used
             as the output filename.

     -v labels
             Set custom table of contents volume labels for each volume.
             Labels must be separated by semicolons, for example:
             "Love//Peace//Hate".

     -x      Extraction mode. Split a merged ePUB back into its original
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

---

### epub-meta

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
             Specify the output directory for generated ePUB files. The
             default is the current directory.

     -f      Force overwrite of existing files with the same name.

     -l lang
             Specify the language code for the merged ePUB (e.g., ko, en, ja,
             zh, ru).

     -O      Disable natural sorting of input files.

     -p prefix
             Add a prefix to table of contents volume labels.

     -q      Quiet mode. Suppress progress messages.

     -s suffix
             Add a suffix to table of contents volume labels.
             Set a custom title for the merged ePUB. This title is also used
             as the output filename.

     -v labels
             Set custom table of contents volume labels for each volume.
             Labels must be separated by semicolons, for example:
             "Love//Peace//Hate".

     -x      Extraction mode. Split a merged ePUB back into its original
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
