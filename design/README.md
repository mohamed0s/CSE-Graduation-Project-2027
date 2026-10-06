# UI/UX Design

**Owner:** UI/UX team

**Figma is the source of truth.** This folder only holds what developers need
from the design: links and exported assets.

## Figma links

| What | Link |
| ---- | ---- |
| Main design file | _add link_ |
| Design system / components | _add link_ |
| Prototype | _add link_ |
| User flows | _add link_ |

## Layout

```
design/
├── assets/       # final exported assets (ready for devs)
│   ├── icons/    # SVG
│   ├── images/   # PNG/WebP, @1x @2x @3x
│   └── logos/
└── flows/        # user-flow / wireframe exports (PNG or PDF)
```

## Handing designs to developers

Developers (Flutter + Frontend) need a few things written down. Put them in Figma, and add a short
`design/style-guide.md` in this folder with the same values so they can copy them:

- Colors (hex), light and dark if used
- Fonts, sizes, weights
- Spacing scale and corner radius
- Icon set and sizes

## Workflow

1. Design in Figma → get feedback from the team.
2. When a screen is **ready for dev**, mark it in Figma (e.g. a "Ready for Dev" page) and tell the devs.
3. Export assets into `design/assets/`.
4. Open a PR (branch `design/<short-description>`) and tag the Flutter + Frontend teams.
5. If a color/font changes in Figma, update `style-guide.md` in the same PR, otherwise the app drifts from the design.

## Rules

- Use names devs can use directly: `ic_home.svg`, `img_onboarding_1.png`, lowercase + underscores.
- Prefer **SVG** for icons.
- Accessibility: text contrast ≥ 4.5:1, tap targets ≥ 48×48.
- You don't need Git expertise: GitHub's web UI (upload files → open a PR) is fine.
