# Markdown Export Risk Review

## Already Broken Today

- `site/posts/undo-history-in-swift.md`
  - Contains a footnote reference written as `[^1]:` in running text.
  - Current footnote link replacement treats `[^x]:` as a definition marker context and does not link it, so this leaks into rendered HTML.

## High-Risk Swift-Authored Posts

- `Sources/Chris/Posts/ViewRepresentable.swift`
  - Heavy use of generated SwiftUI images (`<picture>/<source>/<img>` in HTML output).
  - Needs a Markdown-side representation policy for light/dark screenshots.

- `Sources/Chris/Posts/SafeArea.swift`
  - Multiple generated SwiftUI visualizations.
  - Markdown output likely loses responsive/dark-image behavior unless explicitly represented.

- `Sources/Chris/Posts/Group.swift`
  - Mixed prose and generated screenshots.
  - Risk of lossy conversion for image blocks and captions.

- `Sources/Chris/Posts/SemanticColors.swift`
  - Several generated examples with theme-specific rendering.
  - Requires stable Markdown image strategy.

- `Sources/Chris/Posts/AlignmentGuidesAndIf.swift`
  - Includes generated visual comparison images.
  - Needs explicit markdown mapping for generated assets.

## High-Risk Markdown Posts (Raw HTML Media)

- `site/posts/2023-04.md`
  - Uses raw `<picture>` blocks with dark/light sources.

- `site/posts/matched-geometry-effect.md`
  - Uses raw `<video>/<source>` embeds.

- `site/posts/intentions.md`
  - Uses styled raw `<img>` tags (layout/style carried in HTML attributes).

- `site/posts/2023-17.md`
  - Uses inline raw `<img>` sizing.

- `site/posts/scenery-launch.md`
  - Uses raw `<img>` embed syntax.
