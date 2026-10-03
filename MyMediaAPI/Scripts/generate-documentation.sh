#!/bin/sh

set -eu

script_directory=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
package_root=$(CDPATH= cd -- "$script_directory/.." && pwd)

cd "$package_root"

documentation_directory="./Sources/MyMediaAPI/Resources/documentation"

mkdir -p "$documentation_directory"

swift package \
    --allow-writing-to-directory "$documentation_directory" \
    generate-documentation \
    --target MyMediaAPI \
    --output-path "$documentation_directory" \
    --transform-for-static-hosting \
    --hosting-base-path docs
