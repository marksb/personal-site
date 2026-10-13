Select any text to leave a comment for Claude

## Personal site: Hugo + Tailwind on GitHub Pages

### Context

The repo (`marksb/personal-site`) currently contains only a README — this is a greenfield build. The goal is a minimal, text-optimized personal site/blog written in Markdown, built with Hugo, styled with Tailwind CSS, responsive, deployed to GitHub Pages under the custom domain `marksb.io`, and configured to block all crawlers via `robots.txt`.

Decisions confirmed with the user:

- **Domain**: custom domain `marksb.io` (via CNAME + DNS the user manages).
- **Site title/tagline**: not specified further by the user — using a sensible default (`Mark Backsmeier, tagline "Notes on software, and other things.") in `hugo.toml`. This is a one-line edit for the user to change later; not worth blocking on.

Design decisions (implementer's call, standard/modern choices):

- **No pre-built Hugo theme.** Custom minimal layout built directly with Tailwind utility classes, since the design brief (minimal, text-heavy, Tailwind, responsive) is specific enough that adapting a third-party theme would fight the brief rather than serve it.
- **Tailwind CSS v4 via Hugo's native `css.TailwindCSS` Hugo Pipes integration** (supported since Hugo 0.128+, extended/mounts config in `hugo.toml`). No separate `npm run build` step or PostCSS config needed — `hugo --minify` alone builds the CSS. Requires `package.json` with `tailwindcss` as a devDependency, committed `package-lock.json`, and Node available in the CI build step.
- **Deployment**: GitHub Actions workflow using the official `actions/configure-pages`, `actions/upload-pages-artifact`, and `actions/deploy-pages` actions (the modern GitHub-native deploy flow, not the legacy `gh-pages` branch / `peaceiris/actions-gh-pages` approach). Triggered on push to `main`.
- **robots.txt**: a static `/static/robots.txt` with `User-agent: *` / `Disallow: /` for all bots. (Hugo's built-in `enableRobotsTXT` templated approach is unnecessary complexity for a file this static; a plain static file is simplest and most explicit.) Also set `<meta name="robots" content="noindex, nofollow">` in the base template head as defense in depth, so both crawler-directive channels agree.

### File structure to create

```
personal-site/├── hugo.toml                      # site config: baseURL, Tailwind mounts/build, menus, params├── package.json / package-lock.json  # tailwindcss devDependency├── go.mod (not needed — no Hugo Modules; using npm-based Tailwind CLI resource, not modules)├── archetypes/default.md├── content/│   ├── _index.md                  # home page content (short bio/intro)│   └── posts/│       ├── _index.md              # posts list page front matter (title only)│       └── welcome-to-the-site.md # one sample post so the blog isn't empty├── layouts/│   ├── _default/│   │   ├── baseof.html            # shared shell: head, nav, footer, robots meta│   │   ├── single.html            # single page/post template│   │   └── list.html              # list template (used by posts/_index and home if needed)│   ├── index.html                 # home page template (bio + recent posts list)│   ├── partials/│   │   ├── head.html              # meta tags, css link, title logic│   │   ├── nav.html                # simple text nav: name / posts / about links│   │   └── footer.html│   └── posts/│       └── li.html (optional)     # only if list needs custom item rendering├── assets/│   └── css/│       └── main.css               # @import "tailwindcss"; + minimal custom base styles├── static/│   ├── robots.txt                 # User-agent: * / Disallow: /│   └── CNAME                      # marksb.io└── .github/workflows/deploy.yml   # build + deploy to GitHub Pages on push to main
```

### Design (minimal, text-heavy)

- Single serif or system-ui font stack for body copy, generous line-height (`leading-relaxed`), constrained measure (`max-w-2xl`/`prose`-like width, ~65-75ch) for readability.
- Neutral palette: white/near-white background, near-black text, one muted gray for secondary text (dates, nav), no accent color beyond link underline/hover state. Respect `prefers-color-scheme: dark` with a simple inverted neutral palette via Tailwind's `dark:` variant.
- No sidebar, no hero imagery, no card grids — just a header (name + nav), content column, footer. Post list = title + date, nothing else.
- Responsive via Tailwind's default breakpoints: single column at all sizes, padding/margins scale down on small screens (`px-4 sm:px-6`, etc).
- Use `@tailwindcss/typography` (`prose` classes) for rendering the Markdown post body specifically, since it's built for exactly this (text-heavy long-form content) and pairs naturally with the native Tailwind v4 Hugo pipeline.
- Support dark mode, light mode and browse default.

### hugo.toml key settings

- `baseURL = "https://marksb.io/"`
- `title = "Mark S"`
- `enableRobotsTXT = false` (using the static file instead, avoid double-generation conflicts)
- `[params] tagline = "Notes on software, and other things."`
- `[[menut.main]]` entries for Posts / About (or just Posts, home page doubles as About)
- Markdown/Goldmark defaults are fine (no special config needed)
- Build/mounts config for Tailwind CLI per Hugo's documented native Tailwind v4 setup (mounting `node_modules` so `@import "tailwindcss"` resolves)

### GitHub Actions workflow (deploy.yml)

- Trigger: `on: push: branches: [main]` + `workflow_dispatch`
- Permissions: `contents: read`, `pages: write`, `id-token: write`
- Steps: checkout (with submodules: false, fetch-depth: 0), setup Node (for npm ci / Tailwind), setup Hugo (peaceiris/actions-hugo or manual download, extended version required for Tailwind pipes), `npm ci`, `hugo --minify`, `actions/upload-pages-artifact` on `./public`, then a `deploy` job using `actions/deploy-pages`.
- Note for the user: after this is pushed, they'll need to enable GitHub Pages in repo Settings → Pages → Source: "GitHub Actions" (one-time manual step I can't do from here), and point their DNS for `marksb.io` at GitHub Pages (A/AAAA records or ALIAS/ANAME to `marksb.github.io`), since DNS is outside this repo.

### Verification

- Run `hugo server -D` locally (or in the sandbox) and confirm: home page renders bio + post list, sample post renders with Tailwind typography styling, nav links work, responsive layout looks correct at mobile width (resize/devtools), dark mode toggles correctly via OS preference emulation.
- Run `hugo --minify` and confirm public/robots.txt contains `Disallow: /` and `public/CNAME` contains `marksb.io`.
- Confirm no build errors/warnings from the Tailwind Hugo Pipes integration.
- Sanity-check the generated public/index.html includes the `noindex, nofollow` meta tag.
