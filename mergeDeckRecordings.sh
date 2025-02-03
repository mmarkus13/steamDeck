#!/bin/bash

# Base directory (relative to script location)
BASE_DIR="$(dirname "$0")"
SCRIPT_DIR="$(pwd)" # Directory where the script is located

# Iterate through each subdirectory
for SUBDIR in "$BASE_DIR"/*/; do
    echo "Processing directory: $SUBDIR"

    # Extract subfolder name
    SUBFOLDER_NAME=$(basename "$SUBDIR")

    # Temporary file names
    VIDEO_TMP="${SUBDIR}tmp_video.mp4"
    AUDIO_TMP="${SUBDIR}tmp_audio.mp4"
    FINAL_OUTPUT="${SUBDIR}${SUBFOLDER_NAME}.mp4"
    SCRIPT_FINAL_OUTPUT="${SCRIPT_DIR}/${SUBFOLDER_NAME}.mp4"

    # Skip if the final output already exists in the script directory
    if [ -f "$SCRIPT_FINAL_OUTPUT" ]; then
        echo "Final video already exists: $SCRIPT_FINAL_OUTPUT. Skipping directory."
        continue
    fi

    # List contents of the subdirectory for debugging
    echo "Contents of $SUBDIR:"
    ls -l "$SUBDIR"

    # Add a small delay to ensure filesystem is up-to-date
    sleep 1

    # Check if the required init files are present
    REQUIRED_FILES_PRESENT=true
    if [ -f "${SUBDIR}init-stream0.m4s" ]; then
        echo "Found: ${SUBDIR}init-stream0.m4s"
    else
        echo "Missing: ${SUBDIR}init-stream0.m4s"
        REQUIRED_FILES_PRESENT=false
    fi

    if [ -f "${SUBDIR}init-stream1.m4s" ]; then
        echo "Found: ${SUBDIR}init-stream1.m4s"
    else
        echo "Missing: ${SUBDIR}init-stream1.m4s"
        REQUIRED_FILES_PRESENT=false
    fi

    # Find the first chunk-stream0 and chunk-stream1 files
    CHUNK_STREAM0=$(ls "${SUBDIR}chunk-stream0-"*.m4s | head -n 1)
    CHUNK_STREAM1=$(ls "${SUBDIR}chunk-stream1-"*.m4s | head -n 1)

    if [ -n "$CHUNK_STREAM0" ]; then
        echo "Found: $CHUNK_STREAM0"
    else
        echo "Missing: chunk-stream0 files"
        REQUIRED_FILES_PRESENT=false
    fi

    if [ -n "$CHUNK_STREAM1" ]; then
        echo "Found: $CHUNK_STREAM1"
    else
        echo "Missing: chunk-stream1 files"
        REQUIRED_FILES_PRESENT=false
    fi

    # Proceed with merging if all required files are found
    if [ "$REQUIRED_FILES_PRESENT" = true ]; then
        echo "All required .m4s files found in directory: $SUBDIR"

        # Concatenate video files
        cat "${SUBDIR}init-stream0.m4s" "$CHUNK_STREAM0" "${SUBDIR}chunk-stream0-"*.m4s > "$VIDEO_TMP"

        # Concatenate audio files
        cat "${SUBDIR}init-stream1.m4s" "$CHUNK_STREAM1" "${SUBDIR}chunk-stream1-"*.m4s > "$AUDIO_TMP"

        # Merge video and audio files into final output
        yes N | ffmpeg -i "$VIDEO_TMP" -i "$AUDIO_TMP" -c copy -vsync 2 "$FINAL_OUTPUT"

        # Move final output to script directory
        mv "$FINAL_OUTPUT" "$SCRIPT_FINAL_OUTPUT"

        # Clean up temporary files
        rm "$VIDEO_TMP" "$AUDIO_TMP"

        echo "Merging complete for directory: $SUBDIR. Output file: $SCRIPT_FINAL_OUTPUT"
    else
        echo "Required .m4s files not found in directory: $SUBDIR"
    fi
done

echo "All directories processed."
