#!/bin/bash
# Usage: ./add-asset.sh <file> <name> <type>
# type: characters or scenes
# Example: ./add-asset.sh ~/Downloads/Theseus.jpeg theseus-portrait characters

FILE=$1
NAME=$2
TYPE=${3:-characters}

REPO="/Users/yunongshi/CodeProjects/greek_myth_ios_app"
XCASSETS="$REPO/MythicPathsOlympus/MythicPathsOlympus/Assets.xcassets"
EXT="${FILE##*.}"

# Copy to raw archive
cp "$FILE" "$REPO/assets/raw/$TYPE/$NAME.$EXT"
echo "Saved to assets/raw/$TYPE/$NAME.$EXT"

# Add to Xcode asset catalog
mkdir -p "$XCASSETS/$NAME.imageset"
cp "$FILE" "$XCASSETS/$NAME.imageset/$NAME.$EXT"

cat > "$XCASSETS/$NAME.imageset/Contents.json" << EOF
{
  "images" : [
    {
      "filename" : "$NAME.$EXT",
      "idiom" : "universal",
      "scale" : "1x"
    },
    {
      "idiom" : "universal",
      "scale" : "2x"
    },
    {
      "idiom" : "universal",
      "scale" : "3x"
    }
  ],
  "info" : {
    "author" : "xcode",
    "version" : 1
  }
}
EOF
echo "Added to Xcode assets as \"$NAME\""
echo "Done! Use in SwiftUI: Image(\"$NAME\")"
