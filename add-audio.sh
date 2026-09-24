#!/usr/bin/env bash
# Add audio files to the kotha-audio host and publish them.
#
#   ./add-audio.sh greeting.mp3 test-phrase.mp3
#   ./add-audio.sh ~/Desktop/new-clips/*.mp3
#   ./add-audio.sh                 # just publish whatever is already here
#
# For every clip it also writes a byte-identical .mpga twin. GitHub Pages
# serves .mp3 as "audio/mp3", which is not one of the content types Twilio's
# <Play> documents as supported; .mpga is served as "audio/mpeg", which is.
# Use the .mpga URL in your TwiML.

set -euo pipefail

cd "$(dirname "$0")"

# Public base URL, derived from the git remote:
#   git@github.com:USER/REPO.git  ->  https://user.github.io/REPO
remote="$(git remote get-url origin)"
slug="${remote#*github.com}"
slug="${slug#[:/]}"
slug="${slug%.git}"
user="${slug%%/*}"
repo="${slug##*/}"
base="https://$(echo "$user" | tr '[:upper:]' '[:lower:]').github.io/${repo}"

# 1. Copy in anything passed on the command line.
for src in "$@"; do
  if [[ ! -f "$src" ]]; then
    echo "skipping: no such file: $src" >&2
    continue
  fi
  name="$(basename "$src")"
  if [[ "$(cd "$(dirname "$src")" && pwd -P)" != "$(pwd -P)" ]]; then
    cp -- "$src" "./$name"
    echo "copied in: $name"
  fi
done

# 2. Make sure every .mp3 here has an up-to-date .mpga twin.
shopt -s nullglob
for f in *.mp3; do
  twin="${f%.mp3}.mpga"
  if [[ ! -f "$twin" || "$f" -nt "$twin" ]]; then
    cp -- "$f" "$twin"
    echo "twinned:   $twin"
  fi
done

# 3. Drop orphaned twins whose .mp3 has been deleted.
for twin in *.mpga; do
  [[ -f "${twin%.mpga}.mp3" ]] || { rm -- "$twin"; echo "removed orphan: $twin"; }
done

git add -A

if git diff --cached --quiet; then
  echo "Nothing to publish - already up to date."
  exit 0
fi

names="$(git diff --cached --name-only --diff-filter=ACM -- '*.mp3' | xargs -r -n1 basename | paste -sd' ' -)"
git commit -m "Add audio: ${names:-asset update}"
git push origin main

echo
echo "Pushed. Pages normally goes live within a minute or so."
echo
echo "Twilio <Play> URLs (audio/mpeg):"
for f in *.mp3; do
  echo "  ${base}/${f%.mp3}.mpga"
done
