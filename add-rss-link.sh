#!/bin/bash

# Post-build script to add RSS autodiscovery link to all HTML files
# This is a workaround for Ignite framework limitations

# Get the directory where this script is located
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
DOCS_DIR="$SCRIPT_DIR/docs"

RSS_LINK='<link href="/feed.rss" rel="alternate" type="application/rss+xml" title="Justin Purnell">'

# Create .nojekyll file for GitHub Pages
touch "$DOCS_DIR/.nojekyll"

# Find all HTML files in docs directory and add the RSS link after the canonical link
find "$DOCS_DIR" -name "*.html" -type f -exec sed -i '' "s|<link href=\"https://www.justinpurnell.com/[^\"]*\" rel=\"canonical\">|&$RSS_LINK|" {} \;

echo "✓ RSS autodiscovery links added to all HTML files"
echo "✓ .nojekyll file created"
