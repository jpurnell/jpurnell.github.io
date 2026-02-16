#!/bin/bash

# Post-build script to add RSS autodiscovery link to all HTML files
# This is a workaround for Ignite framework limitations

RSS_LINK='<link href="/feed.rss" rel="alternate" type="application/rss+xml" title="Justin Purnell">'

# Create .nojekyll file for GitHub Pages
touch docs/.nojekyll

# Find all HTML files in docs directory and add the RSS link after the canonical link
find docs -name "*.html" -type f -exec sed -i '' "s|<link href=\"https://www.justinpurnell.com/[^\"]*\" rel=\"canonical\">|&$RSS_LINK|" {} \;

echo "RSS autodiscovery links added to all HTML files"
echo ".nojekyll file created"
