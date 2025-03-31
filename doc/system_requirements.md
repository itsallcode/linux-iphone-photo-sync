# Linux iPhone Photo Sync (LIPS)

## Terms and Abbreviations

###### High Efficiency Image Coding (HEIC)

The HEIC is a file format used for storing images. It provides higher image quality and compression than traditional formats like JPG. It's widely used in Apple's IOS and macOS devices but isn't universally supported on all platforms.

## Features

### Photo Synchronization
`feat~photo-synchronization~1`

LIPS does a one-way sync of images from an iPhone via USB onto a Linux machine.

Needs: req

### JPEG Conversion
`feat~jpeg-conversion~1`

LIPSync converts the downloaded HEIC images to JPEG format.

Needs: req

## High-level Requirements

### Photo Synchronization

#### Debian Linux Dependencies Only
`req~debian-linux-dependencies-only~1`

LIPS requires only tools and libraries which are available on a Debian 12 or derived (e.g. Ubuntu) system.

Covers:

* [`feat~photo-synchronization~1`](#photo-synchronization)

Needs: dsn

#### Incremental Photo Download
`req~incremental-photo-download~1`

LIPS downloads only photos that are not yet in the target directory.

Rationale:

This speeds up the download process and makes restarting after interrupted download more reliable.

Covers:

* [`feat~photo-synchronization~1`](#photo-synchronization)

Needs: dsn

### JPG Conversion

#### JPEG Incremental Conversion
`req~jpeg-incremental-conversion~1`

LIPS converts all HEIC files for which no JPEG exists into a JPEG file in a separate export directory.

Covers:

* [`feat~jpeg-conversion~1`](#jpeg-conversion)

Needs: dsn