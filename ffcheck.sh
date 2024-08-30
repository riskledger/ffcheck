#!/bin/bash
set -x

base_commit=$1
head_commit=$2

if [ -z "$base_commit" ] || [ -z "$head_commit" ]; then
    echo "Usage: $0 <base_commit> <head_commit>"
    exit 1
fi

echo "Base $base_commit"
echo "Head $head_commit"

fe_files=$(git diff --name-only "$base_commit" "$head_commit" | grep -E '\.vue$|\.ts$')
echo $(git diff --name-only "$base_commit" "$head_commit")
echo "FE files $fe_files"
go_files=$(git diff --name-only "$base_commit" "$head_commit" | grep '\.go$')
missing_flags=()

for file in $fe_files; do
	if ! grep -q "ff(" "$file"; then
        missing_flags+=("$file")
	fi
done

for file in $go_files; do
	if ! grep -q "Enabled(ctx)" "$file"; then
        missing_flags+=("$file")
	fi
done

if [ ${#missing_flags[@]} -ne 0 ]; then
    echo "Files missing feature flag usage:"
    printf '%s\n' "${missing_flags[@]}"
    exit 1
else
    echo "All new or modified files use feature flags."
    exit 0
fi
