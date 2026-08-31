# AGENTS.md

## Blog Post Helper

When asked to create a new blog post, use this template and rules.

### Rules
- Create the file in `site/posts/`.
- Use `YYYY-MM-DD` for the date in frontmatter.
- Use a short, readable filename (slug-like, kebab-case).
- Include `title` and `headline` in frontmatter.
- If title/headline/slug are missing, ask the user.
- If the user provides a clear post title in the content, use that for `title` and derive the slug from it.
- If the user provides a relative date like "tomorrow", convert it to an explicit `YYYY-MM-DD` date.
- When in doubt about formatting, check recent posts in `site/posts/` to match the established style.

### Template
```markdown
---
date: YYYY-MM-DD
title: Title Goes Here
headline: Short Headline
---

First paragraph.
```

### Example Command
```sh
cat <<'EOF' > site/posts/my-new-post.md
---
date: 2026-02-05
title: My New Post
headline: A Short Headline
---

Write the post here.
EOF
```

## Build And Preview

- To generate the site, run `swift run Website`. Plain `swift run` is
  ambiguous because this package also contains `PreviewServer`.
- Run the test suite with `swift test`.
- To preview the generated site locally, run
  `python3 -m http.server 8765 --bind 127.0.0.1 --directory docs`.

## Generated Interactive Assets

- `site/js/shake-comparison.js` and `docs/js/shake-comparison.js` are generated
  by the SwiftUI reimplementation repository. Do not edit either copy by hand.
- From `/Users/chris/gmbh/code/SwiftUIReimplNew`, run
  `./Scripts/sync-shake-review.sh /Users/chris/Sites/chriseidhofnl` to regenerate
  the review and update both copies from one source.
- If only those JavaScript copies changed, a full website rebuild is not
  required. If post Markdown or templates changed, run `swift run Website` so
  `docs/` and feeds stay synchronized.
- Inspect `git status` before staging. Post prose may be an intentional author
  edit made alongside generated-asset work; do not include it in an asset-only
  commit unless requested.
