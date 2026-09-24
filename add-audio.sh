#!/usr/bin/env bash
# Add audio files to the kotha-audio host and publish them.
#
#   ./add-audio.sh greeting.mp3 test-phrase.mp3
#   ./add-audio.sh ~/Desktop/new-clips/*.mp3
#   ./add-audio.sh                 # just commit+push whatever is already here
#
# Prints the public GitHub Pages URL for each file when it finishes.

set -euo pipefail

cd "$(dirname "$0")"

# Work out the public base URL from the git remote: git@github.com:USER/REPO.git
# or https://github.com/USER/REPO.git  ->  https://USER.github.io/REPO
remote="$(git remote get-url origin)"
slug="${remote#*github.com[:/]}"
slug="${slug%.git}"
user="${slug%%/*}"
repo="${slug##*/}"
base="https://${user}.github.io/${repo}"

added=()

for src in "$@"; do
  if [[ ! -f "$src" ]]; then
    echo "skipping: no such file: $src" >&2
    continue
  fi
  name="$(basename "$src")"
  # Only copy if it came from somewhere else.
  if [[ "$(cd "$(dirname "$src")" && pwd)" != "$(pwd)" ]]; then
    cp "$src" "./$name"
    echo "copied in: $name"
  fi
  added+=("$name")
done

git add -A

if git diff --cached --quiet; then
  echo "Nothing to publish - working tree is already up to date."
  exit 0
fi

if [[ ${#added[@]} -gt 0 ]]; then
  msg="Add audio: ${added[*]}"
else
  msg="Update audio assets"
fi

git commit -m "$msg"
git push origin main

echo
echo "Pushed. GitHub Pages usually goes live within ~1 minute."
echo "Public URLs:"
if [[ ${#added[@]} -gt 0 ]]; then
  for name in "${added[@]}"; do
    echo "  ${base}/${name}"
  done
else
  for f in *.mp3 *.wav; do
    [[ -e "$f" ]] && echo "  ${base}/${f}"
  done
fi
