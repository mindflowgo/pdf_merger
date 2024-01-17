#!/bin/bash

# This file is useful if you are wanting to take a number of screenshots (jpgs), ex from an online book,
# and then crop parts of each image, and convert them into PDFs, ultimately cocatenating them into a single PDF
# Free to use as you wish, I provide NO warranties. ~ Fil (fil@rezox.com)

convert_file() {
    local file=$1
    local DEST_DIR=$2
    local COMPRESSION_QUALITY=$3
    local X_CROP=$4
    local Y_CROP=$5
    local WIDTH_CROP=$6
    local HEIGHT_CROP=$7
    local new_width
    local new_height

    # Get image height and width
    read width height <<< $(identify -format "%w %h" "$file")

    # New width after cropping
    new_width=$((width - $WIDTH_CROP))

    # New height after cropping
    new_height=$((height - $HEIGHT_CROP))

    # Crop and save in the specified directory
    convert "$file" -crop ${width}x${new_height}+${X_CROP}+${Y_CROP} -quality $COMPRESSION_QUALITY "$DEST_DIR/${file}.pdf"
    echo "  .. $file [${width}x${height}] > [${new_width}x${new_height}+${X_CROP}+${Y_CROP}] @ ${COMPRESSION_QUALITY}% quality"
}

# Check if ImageMagick/GhostScript are installed
if ! command -v convert &> /dev/null; then
    echo "ImageMagick is not installed ('convert' tool). Please install it to use this script."
    exit 1
fi
if ! command -v gs &> /dev/null; then
    echo "GhostScript is not installed ('gs' tool). Please install it to use this script."
    exit 1
fi

# Set the compression quality (1-100)
COMPRESSION_QUALITY=60
DEST_DIR="final"
DEST_NAME="_final.pdf"
X_CROP=0
Y_CROP=0
WIDTH_CROP=0
HEIGHT_CROP=60

# Create a subdirectory for the processed images
mkdir -p "$DEST_DIR"

# Check if file names are provided
if [ $# -eq 0 ]; then
    # No filenames provided; process all jpg files
    echo "Converting all jpgs first..."
    for file in *.jpg; do
        [ -f "$file" ] && convert_file "$file" "$DEST_DIR" $COMPRESSION_QUALITY $X_CROP $Y_CROP $WIDTH_CROP $HEIGHT_CROP
    done
    # Combine all processed images into a single PDF
    #convert "$DEST_DIR/*.pdf" "_final.pdf"
    # much faster than the convert option.
    echo " .. conversion done, now merging into a final $DEST_NAME."
    gs -dBATCH -dNOPAUSE -q -sDEVICE=pdfwrite -sOutputFile="$DEST_NAME" "$DEST_DIR"/*.pdf
    echo "Finished!"
else
    # Filenames provided; process each file separately
    for file in "$@"; do
        if [ -f "$file" ]; then
            convert_file "$file" "$DEST_DIR" $COMPRESSION_QUALITY $X_CROP $Y_CROP $WIDTH_CROP $HEIGHT_CROP
        else
            echo "! File $file not found."
        fi
    done
fi

echo "Processing completed."
