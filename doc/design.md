# System Design Specification - Linux iPhone Photo Sync (LIPS)

## Introduction

This document presents the design decision made in LIPSync which meet the requirements outlined in system_requirements.md.

## Structural View

### Debian Linux Dependencies Only

To ensure compatibility and mitigate dependency issues, LIPSync is designed to use only tools and libraries available on Debian 12 or derivatives like Ubuntu.

#### Required Packages
`dsn~required-packages~1`

LIPS requires the following packages. All of them are available on a vanilla Debian-based system:

| Package                  | Purpose                           |
|--------------------------|-----------------------------------|
| `libimobiledevice6`      | Library to access iPhones / iPads |
| `libimobiledevice-utils` | Binaries to use iPhone functions  |
| `imagemagick`            | Image conversion                  |                 

Covers:

* `req~debian-linux-dependencies-only~1`

## Runtime View

## Incremental Photo Download

LIPS incorporates an incremental photo download feature. This means it skips downloading photos that already exist in the target directory. This approach optimizes the download process by avoiding unnecessary duplication and facilitating the resumption of interrupted downloads.

### RSync for DCIM Directory
`dsn~rsync-for-dcim-directory~1`

LIPS uses `rsync` to incrementally download images from the iPhones `DCIM` directory.

Covers:

* `req~incremental-photo-download~1`

### iPhone Mount
`dsn~iphone-mount~1`

LIPS mounts the iPhone via iFuse under `<home>/mnt/iPhone`.

Covers:

* `req~incremental-photo-download~1`

### Picture Directory
`dsn~picture-directory~1`

LIPS reads the user picture directory from the user config.

Covers:

* `req~incremental-photo-download~1`

### Fallback Picture Directory
`dsn~fallback-picture-directory~1`

If the picture directory is not given in the user config, LIPS falls back to `<home>/Pictures`.

Covers:

* `req~incremental-photo-download~1`

### Original Photos Directory
`dsn~original-photos-directory~1`

LIPS syncs the original content of the iPhones `DCIM` directory to `<pictures>/original_photos`.

Covers:

* `req~incremental-photo-download~1`

## JPEG Conversion

Similarly, the script is designed to incrementally convert HEIC files to JPEG. It checks if a JPEG copy of the HEIC file already exists before carrying out the conversion. If the JPEG copy exists, the conversion process is skipped. This design approach optimizes CPU usage and processing time.

### Check JPEG Existence in Target Directory
`dsn~check-jpeg-existence-in-target-directory~1`

LIPS checks if the JPEG already exists in the target directory. If it does, LIPS skips the export.

Covers:

* `req~jpeg-incremental-conversion~1`

### Convert HEIC to JPEG With ImageMagick
`dsn~convert-heic-to-jpeg-with-imagemagick~1`

LIPS uses the `convert` tool from the ImageMagick suite to convert images from HEIC to JPG.

Covers:

* `req~jpeg-incremental-conversion~1`

### Fixed JPEG Quality of 85%
`dsn~fixed-jpeg-quality-of-85-percent~1`

LIPS converts HEIC to JPEGs at a fixed quality of 85%.

Covers:

* `req~jpeg-incremental-conversion~1`

### JPEG Export Directory
`dsn~jpeg-export-directory~1`

LIPS exports JPEGs to `<pictures>/exported_jpgs`.

Covers:

* `req~jpeg-incremental-conversion~1`

### Copy Existing JPEGs
`dsn~copy-existing-jpegs~1`

LIPS uses `rsync` to copy existing JPEGs to the export directory.

Covers:

* `req~jpeg-incremental-conversion~1`