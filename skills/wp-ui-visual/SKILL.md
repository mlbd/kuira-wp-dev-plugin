---
name: wp-ui-visual
description: >
  WordPress UI/UX and visual design skill. Triggers on any task involving
  admin UI, block editor components, form design, modal/dialog, settings page,
  WooCommerce product display, dashboard widget, metabox layout, color palette,
  CSS/SCSS work, React component in WordPress, Gutenberg block UI, canvas mockup,
  or any phrase like "design", "layout", "looks like", "UI", "UX", "visual",
  "mockup", "wireframe", "component", "style", "theme", "admin page design".
  Routes to Superpowers visual companion when available.
allowed-tools: Read, Bash, Glob
model: sonnet
---

## WordPress UI/UX Visual Design Workflow

### Step 1 — Detect Superpowers

Before doing any visual work, check if Superpowers is installed:

```bash
ls ~/.claude/plugins/ 2>/dev/null | grep -i superpowers || \
ls ~/.claude/skills/ 2>/dev/null | grep -i superpowers || \
echo "superpowers-not-found"
```

**If Superpowers is installed:**
→ Invoke `/superpowers:brainstorming` immediately.
→ Tell the user: "I'm routing this to Superpowers brainstorming — it will offer the Visual Companion for interactive mockups in your browser."
→ The visual companion will open at a local URL showing layout options, color palettes, and component alternatives as interactive cards.
→ Do NOT write any code until the brainstorming + visual companion phase is complete and the user has signed off on a design direction.

**If Superpowers is NOT installed:**
→ Remind the user: "Install Superpowers first for the visual companion: `/plugin marketplace add obra/superpowers-marketplace` then `/plugin install superpowers@superpowers-marketplace`"
→ Fall through to the standalone visual workflow below.

---

### Standalone Visual Workflow (no Superpowers)

When Superpowers is unavailable, use this structured approach:

**1. Clarify before designing**
Ask these questions (one at a time, not a list dump):
- Is this for WordPress admin, frontend, or Gutenberg editor?
- What existing WP UI patterns should it match? (admin menu, metabox, WooCommerce settings, etc.)
- Mobile/responsive required?
- Any existing color palette, CSS variables, or design tokens to respect?

**2. Present 2–3 design directions**
Generate minimal HTML/CSS mockups using WordPress admin CSS classes where possible:
- `wrap`, `wp-header-end`, `notice`, `postbox`, `inside` — native WP admin classes
- `woocommerce-BlankState`, `wc-tabs` — WooCommerce admin classes
- For block editor: use `@wordpress/components` primitives

**3. Reference WordPress design patterns**
- Settings pages → use `<form method="post" action="options.php">` + `settings_fields()`
- Admin tables → `WP_List_Table` patterns
- Metaboxes → `add_meta_box()` + nonce pattern
- Modals → `wp.media` or `@wordpress/components` `Modal`
- Notifications → `admin_notices` action + dismissible class

**4. For React/Gutenberg components**
- Use `@wordpress/components`: `Button`, `TextControl`, `SelectControl`, `ToggleControl`, `Panel`, `PanelBody`
- Import from `@wordpress/element` not raw React
- Use `@wordpress/data` for store access
- Follow block.json schema for block registration

---

## Visual Companion Note

The Superpowers visual companion opens a local browser URL with:
- **Layout cards** — 3 design approaches side by side
- **Color palette picker** — interactive swatches
- **Component alternatives** — different UI patterns for the same feature
- **Wireframe sketches** — low-fidelity structure before full mockup

This is most valuable for: new admin pages, WooCommerce product display redesigns,
Gutenberg block UI, form builder field types, mockup canvas layouts, dashboard widgets,
and any multi-step or stateful admin interface.

Always use the Visual Companion phase before writing any PHP templates, React components,
or CSS — a 15-minute visual decision prevents hours of rework.
