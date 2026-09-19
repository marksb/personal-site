# personal-site

Source for [marksb.io](https://marksb.io/) — a minimal, text-first personal
site and blog, written in Markdown, built with [Hugo](https://gohugo.io/)
and [Tailwind CSS](https://tailwindcss.com/), deployed to GitHub Pages.

## Local development

Requires Node 22.x and [Hugo](https://gohugo.io/) 0.150.x (extended
edition — the Tailwind CSS integration depends on it).

```sh
npm ci
make dev     # hugo server -D, http://localhost:1313
make build   # hugo --minify, outputs to ./public
make check   # build, then check for broken internal links/media
             #   (requires the `lychee` CLI: https://github.com/lycheeverse/lychee)
```

## Writing a post

Add a Markdown file under `content/posts/`, named after the slug (no date
prefix — the URL is `/posts/<slug>/`), e.g. `content/posts/my-post.md`:

```markdown
---
title: "My post"
date: 2026-01-01
tags: ["optional", "tags"]
draft: false   # omit or set true to keep it out of production builds
---

Body text in Markdown.
```

`draft: true` posts are visible with `make dev` / `hugo server -D` but are
excluded from `make build` and from CI/production builds.

## Deployment

Every push to `main` builds the site and deploys it to GitHub Pages via
GitHub Actions (`.github/workflows/pages.yml`); pull requests get a
build-only check. `public/` is never committed — it's produced fresh by CI
and uploaded as a Pages artifact.

One-time setup for a new deployment target:

1. **Pages source**: in the repo's Settings → Pages, set "Source" to
   "GitHub Actions".
2. **DNS for marksb.io**: point the apex domain at GitHub Pages by adding
   `A` records for `185.199.108.153`, `185.199.109.153`, `185.199.110.153`,
   and `185.199.111.153` (or `ALIAS`/`ANAME` records if your DNS provider
   supports them). A `CNAME` file in `static/` already tells Pages to serve
   the site at `marksb.io`.
3. **www → apex redirect**: add a `CNAME` record for `www.marksb.io`
   pointing at `marksb.io`, and configure it to redirect to the apex domain
   (via your DNS/registrar's redirect feature, or a separate redirect
   service) — `https://marksb.io/` is the canonical host; `www` should not
   serve content directly.

## Rights

Code in this repository is licensed under the [MIT License](./LICENSE).

Written content (posts, pages) is **all rights reserved** — © the current
year, Mark Backsmeier — and is not covered by the code license.
