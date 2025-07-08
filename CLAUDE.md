# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Build Commands

- **Build the website**: `swift run Website`
- **Run tests**: `swift test`
- **Docker build**: `./docker.sh` (cross-platform Swift development)
- **Copy Swift syntax parser**: `./copy.sh` (fixes SwiftSyntax parser library path issues)
- **Run local server**: `python3 -m http.server` (run in docs directory)

## Architecture

This is a Swift-based static site generator for Chris Eidhof's personal website. The codebase uses Swift Package Manager and consists of several modules:

### Core Modules

- **Website**: Main executable target that runs the site generation
- **Chris**: Core website logic and content structure
- **Helpers**: Utility functions for syntax highlighting, link checking, date formatting, etc.
- **SwiftUIViews**: SwiftUI-based view components for the website

### Key Dependencies

- **StaticSite**: Custom static site generation framework (local dependency)
- **Swim**: HTML generation library
- **Yams**: YAML parsing for frontmatter
- **SwiftSyntax**: Swift code parsing for syntax highlighting

### Site Structure

- **Sources/**: Swift source code organized by module
- **site/**: Input content (markdown posts, images, CSS, etc.)
- **docs/**: Generated output directory (published to GitHub Pages)
- **Tests/**: Unit tests

### Content Organization

- Blog posts are stored in `site/posts/` as Markdown files
- Presentations are in `site/presentations/`
- Notes are in `site/notes/`
- Static assets (images, CSS, movies) are in `site/` subdirectories

### Build Process

The site generation process (`Sources/Chris/Run.swift`):
1. Recreates the build directory (`docs/`)
2. Processes content using the StaticSite framework
3. Applies syntax highlighting and link checking
4. Outputs static HTML to `docs/` for GitHub Pages hosting

### Development Notes

- The site uses a custom StaticSite framework for content processing
- SwiftSyntax is used for code syntax highlighting
- Link checking is performed during build to catch broken internal links
- The build process includes caching for performance
- Output is optimized for GitHub Pages hosting
