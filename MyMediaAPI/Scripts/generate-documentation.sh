#!/bin/sh

set -eu

script_directory=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
package_root=$(CDPATH= cd -- "$script_directory/.." && pwd)

cd "$package_root"

if [ -n "${TARGET_BUILD_DIR:-}" ] && [ -n "${UNLOCALIZED_RESOURCES_FOLDER_PATH:-}" ]; then
    documentation_directory="$TARGET_BUILD_DIR/$UNLOCALIZED_RESOURCES_FOLDER_PATH/documentation"
else
    documentation_directory="$package_root/.build/GeneratedDocumentation"
fi

mkdir -p "$documentation_directory"

swift package \
    --allow-writing-to-directory "$documentation_directory" \
    generate-documentation \
    --target MyMediaAPI \
    --output-path "$documentation_directory" \
    --transform-for-static-hosting \
    --hosting-base-path docs
