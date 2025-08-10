#!/bin/bash
set -e

# Variables
TAG_NAME=$1
if [ -z "$TAG_NAME" ]; then
  echo "Usage: $0 <tag_name>"
  exit 1
fi

CLEAN_TAG=$(echo "$TAG_NAME" | sed 's/^1\.0\.//')
CURRENT_DATE=$(date +"%Y-%m-%d")

# Update .toc version
sed -i "s/## Version: .*/## Version: $CLEAN_TAG/" SAP_Raid_Updater.toc
echo "Updated TOC version to $CLEAN_TAG"

# Get commit log
PREV_TAG=$(git tag --sort=-creatordate | grep -v "$TAG_NAME" | head -n 1 || true)
COMMIT_LOG=$(git log "${PREV_TAG:+$PREV_TAG..}$TAG_NAME" --pretty=format:"- %s" | grep '\[sap\]' | grep -v '\[skip ci\]' || true)

if [ -z "$COMMIT_LOG" ]; then
  echo "No relevant commits found."
  exit 0
fi

# Write changelog
{
  echo "## $TAG_NAME ($CURRENT_DATE)"
  echo "$COMMIT_LOG" | sed 's/\[sap\]//g'
  echo
  [ -f CHANGELOG.md ] && cat CHANGELOG.md
} > CHANGELOG.md.new
mv CHANGELOG.md.new CHANGELOG.md
echo "Changelog updated."

# Prepare JSON for Discord
VERSION_LINE="## $TAG_NAME ($CURRENT_DATE)"
CHANGELOG_TEXT=$(echo "$COMMIT_LOG" | sed 's/\[sap\]//g' | sed ':a;N;$!ba;s/\n/\\n/g' | sed 's/"/\\"/g')

EMBEDS='[
  {
    "title": "New Version Deployed",
    "description": "**'"$VERSION_LINE"'**\n\n📝 Changelog:\n'"$CHANGELOG_TEXT"'",
    "color": 1127128
  }
]'

echo "Discord embed JSON prepared:"
echo "$EMBEDS"