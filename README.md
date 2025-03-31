# Linux iPhone Photo Sync (LIPS)

This project provides a small Bash script that does an incremental synchronization of the photos on your iPhone to a Linux machine.

It also exports all photos from HEIC to JPEG format in a separate directory.

## Features

1. Incremental sync from iPhone photos to a local directory
2. Export of all HEIC images to JPEG
3. Fully automatic operation

## Installation

Before you can run the script, please install the following packages:

```shell
sudo apt install libimobiledevice6 libimobiledevice-utils imagemagick
```

## Running the Script

You simply run the script without any parameters.

```shell
./lips.sh
```

The script will create the following directories:

| Directory                              | Purpose                                                          |
|----------------------------------------|------------------------------------------------------------------|
| `~/mnt/iPhone`                         | Mount point for the iPhone (source from where to copy the files) |
| `<picture-dir>/iPhone/original_photos` | Directory to which the original photos are synched               |
| `<picture-dir>/iPhone/exported_jpgs`   | Target directory for JPGs convered from HEIC                     |

## Developer Information

If you want to build the project, please install the following additional packages 

```shell
sudo apt install shellcheck
```

### Static Code Analysis

To run static code analysis, please execute:

```shell
tools/shellcheck.sh
```