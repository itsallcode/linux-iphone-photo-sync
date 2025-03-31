#!/usr/bin/env bash

set -euo pipefail

# Get the standard user directory for pictures.
# Falls back to "Pictures" if not set.
if [ -f "$HOME/.config/user-dirs.dirs" ]; then
    # shellcheck disable=SC1091
    source "$HOME/.config/user-dirs.dirs"
    pictures_dir="$XDG_PICTURES_DIR"
else
    pictures_dir="$HOME/Pictures"
fi

# Set source and target paths.
readonly iphone_fuse_dir="$HOME/mnt/iPhone"
readonly photo_source_dir="$iphone_fuse_dir/DCIM"
readonly photo_target_dir="$pictures_dir/iPhone/original_photos"
readonly jpg_export_dir="$pictures_dir/iPhone/exported_jpgs"

# General constants
readonly jpeg_quality=85
readonly exit_software=1
readonly exit_ok=0

create_directories_if_missing() {
    for dir in "${iphone_fuse_dir}" "${photo_target_dir}" "${jpg_export_dir}"; do
    if [ ! -d "${dir}" ]; then
        echo "${dir} does not exist. Creating..."
        mkdir --parents "${dir}"
    fi
done
}

pair_iphone() {
    # Get the device's unique Device ID:
    udid=$(idevice_id -l)

    # Check if the device is paired:
    if idevicepair -u "${udid}" validate >/dev/null 2>&1; then
        echo "iPhone is already paired: ${udid}"
    else
        echo "iPhone is not paired. Attempting to pair..."
        idevicepair -u "${udid}" pair

        # Validate if pairing was successful:
        if idevicepair -u "${udid}" validate >/dev/null 2>&1; then
            echo "Pairing successful: ${udid}"
        else
            echo "Pairing failed. Please unplug and replug the device, or restart the device."
        fi
    fi
}

mount_iphone() {
    if mountpoint -q "${iphone_fuse_dir}"; then
        echo "iPhone is already mounted at \"${iphone_fuse_dir}\"."
    else
        echo "Attempting to mount iPhone at \"${iphone_fuse_dir}\"."
        if ifuse "${iphone_fuse_dir}"; then
            echo "iPhone mounted at ${iphone_fuse_dir}"
        else
            echo "Failed to mount iPhone. Please make sure it is plugged in and the screen is unlocked."
        fi
    fi
}

sync_photos() {
    echo "Synchronizing photos from \"$photo_source_dir\" to \"$photo_target_dir\"..."
    rsync --archive --progress --human-readable --delete "$photo_source_dir/" "$photo_target_dir/"
}

export_to_jpeg() {
    echo "Exporting HEIC from \"$photo_target_dir\" to JPEGs \"$jpg_export_dir\"..."
    trap "echo 'Exporting to JPEG interrupted. Exiting...'; exit 1;" SIGINT SIGTERM

    while IFS= read -r -d '' source_file; do
      rel_path=$(realpath --relative-to="$photo_target_dir" "$source_file")
      dir_path=$(dirname "$rel_path")
      mkdir -p "$jpg_export_dir/$dir_path"
      base_name=$(basename "$source_file" .HEIC)
      target_file="${jpg_export_dir}/${dir_path}/${base_name}.jpg"
      if [ ! -e "${target_file}" ]; then
          echo "Converting \"${source_file}\" to \"${target_file}\"."
          convert -quality "${jpeg_quality}" "${source_file}" "${target_file}"
          # preserve timestamp
          touch -r "${source_file}" "${target_file}"
      fi
  done < <(find "${photo_target_dir}" -type f -iname '*.HEIC' -print0)
}

sync_existing_jpgs() {
    echo "Exporting HEIC from \"$photo_target_dir\" to JPEGs \"$jpg_export_dir\"..."
    rsync -m --include='*.jpg' --include='*.JPG' --include='*.jpeg' --include="*,JPEG" \
        --exclude='*' -a --progress "$photo_target_dir/" "$jpg_export_dir/"
}

unmount_iphone() {
    if mountpoint -q "${iphone_fuse_dir}"; then
        echo "Unmounting iPhone from \"${iphone_fuse_dir}\"."
        if umount "${iphone_fuse_dir}"; then
            echo "Successfully unmounted iPhone. You can unplug it now."
        else
            echo "Failed to unmount iPhone. You might need to sudo or check if other processes are using files within the mounted directory."
        fi
    else
        echo "iPhone is already unmounted."
    fi
}

create_directories_if_missing &&
pair_iphone &&
mount_iphone &&
sync_photos &&
unmount_iphone &&
sync_existing_jpgs &&
export_to_jpeg || exit "$exit_software"

exit "$exit_ok"