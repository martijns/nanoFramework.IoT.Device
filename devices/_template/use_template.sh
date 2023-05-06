#!/bin/bash

TARGET_PROJECT_NAME=${TARGET_PROJECT_NAME:-$1}

if [[ "$TARGET_PROJECT_NAME" == "" ]]; then
    echo "Usage: $0 <project name>"
    exit 1
fi

THIS_SCRIPT="$(readlink -f ${BASH_SOURCE[0]})"
THIS_FILENAME="$(basename $THIS_SCRIPT)"
THIS_DIR="$(dirname $THIS_SCRIPT)"
PARENT_DIR="$(dirname $THIS_DIR)"
TARGET_DIR="$PARENT_DIR/$TARGET_PROJECT_NAME"
PROJECT_UUID="$(od -x /dev/urandom | head -1 | awk '{OFS="-"; print $2$3,$4,$5,$6,$7$8$9}')"
PROJECT_UUID=${PROJECT_UUID^^}
SAMPLE_UUID="$(od -x /dev/urandom | head -1 | awk '{OFS="-"; print $2$3,$4,$5,$6,$7$8$9}')"
SAMPLE_UUID=${SAMPLE_UUID^^}

if [[ -e "$TARGET_DIR" ]]; then
    echo "Target already exists ($TARGET_DIR)"
    exit 1
fi

echo "[X] Copying template to $TARGET_DIR"
cp -R "$THIS_DIR" "$TARGET_DIR"

echo "[X] Updating directory names"
for file in `find "$TARGET_DIR" -depth -name "*Template*" -type d`; do
    mv "$file" "${file/Template/$TARGET_PROJECT_NAME}"
done

echo "[X] Updating file names"
for file in `find "$TARGET_DIR" -depth -name "*Template*" -type f`; do
    mv "$file" "${file/Template/$TARGET_PROJECT_NAME}"
done

echo "[X] Updating file contents from Template to $TARGET_PROJECT_NAME"
find "$TARGET_DIR" -type f -name "*.*" -exec sed -i "s/Template/$TARGET_PROJECT_NAME/g" {} +

echo "[X] Update project GUID"
find "$TARGET_DIR" -type f \( -iname "*.nfproj" -or -iname "*.sln" \) -exec sed -i "s/11111111-1111-1111-1111-111111111111/$PROJECT_UUID/g" {} +

echo "[X] Update sample project GUID"
find "$TARGET_DIR" -type f \( -iname "*.nfproj" -or -iname "*.sln" \) -exec sed -i "s/22222222-2222-2222-2222-222222222222/$SAMPLE_UUID/g" {} +

echo "[X] Done!"
