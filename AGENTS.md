# AGENTS.md

## Blog Post Helper

When asked to create a new blog post, use this template and rules.

### Rules
- Create the file in `site/posts/`.
- Use `YYYY-MM-DD` for the date in frontmatter.
- Use a short, readable filename (slug-like, kebab-case).
- Include `title` and `headline` in frontmatter.
- If title/headline/slug are missing, ask the user.

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
