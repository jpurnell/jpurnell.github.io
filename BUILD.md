# Build Instructions

## Building from Command Line

Simply run:
```bash
swift run
```

This will:
1. Build the site to the `docs/` directory
2. Automatically add RSS autodiscovery links to all HTML files
3. Create the `.nojekyll` file for GitHub Pages

## Building from Xcode

### Option 1: Set Working Directory (Recommended)

1. In Xcode, go to **Product > Scheme > Edit Scheme...**
2. Select **Run** in the left sidebar
3. Click the **Options** tab
4. Check **Use custom working directory**
5. Set it to: `/Users/jpurnell/Dropbox/Computer/Development/Swift/justinpurnell.com`
6. Click **Close**

Now you can run the project from Xcode with ⌘R and the post-build script will work.

### Option 2: Run Post-Build Script Manually

If you don't set the working directory, you'll see a warning after build. Simply run:
```bash
./add-rss-link.sh
```

from the project root directory in Terminal.

## What the Post-Build Script Does

The `add-rss-link.sh` script:
- Adds RSS autodiscovery `<link>` tags to all HTML files
- Creates `.nojekyll` file for GitHub Pages compatibility

This is necessary because the Ignite framework doesn't support custom attributes on MetaLink elements.

## RSS Feed

Your RSS feed is available at:
- https://www.justinpurnell.com/feed.rss

RSS readers can now autodiscover this feed from any page on your site.
