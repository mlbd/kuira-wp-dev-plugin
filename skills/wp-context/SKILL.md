---
name: wp-context
description: >
  WordPress development context. Auto-loads on any WordPress project.
  Provides WPCS rules, text domain discipline, hook naming conventions,
  escaping/sanitization standards, and plugin architecture patterns.
  Triggers on any PHP file edit in a WP plugin or theme context.
allowed-tools: Read, Glob, Bash
paths:
  - "**/*.php"
  - "**/plugin.php"
  - "**/functions.php"
  - "**/wp-content/**"
  - "**/includes/**"
disable-model-invocation: false
---

## WordPress Coding Standards (WPCS) — Always Enforce

**Indentation:** Tabs, not spaces.

**Naming:**
- Functions/variables: `snake_case`
- Classes: `PascalCase`
- Constants: `UPPER_SNAKE_CASE`
- Hooks: `{plugin_prefix}_{context}_{action}` e.g. `oasis_wf_before_submit`

**Text domain:** Use only the registered slug. Never hardcode strings without `__()` or `_e()`.
- Oasis Workflow Pro → `oasiswf`
- Formcierge → `formcierge`
- Mockivo → `mockivo`
- Postyra → `postyra`
- Lineflow → `lineflow`

**Escaping — required before every output:**
| Context | Function |
|---------|----------|
| HTML output | `esc_html()` |
| HTML attribute | `esc_attr()` |
| URL | `esc_url()` |
| JS inline | `esc_js()` |
| Rich HTML | `wp_kses_post()` |

**Sanitization — required on every input:**
| Data type | Function |
|-----------|----------|
| Text | `sanitize_text_field()` |
| Textarea | `sanitize_textarea_field()` |
| Email | `sanitize_email()` |
| Integer | `absint()` or `intval()` |
| URL | `esc_url_raw()` |
| HTML | `wp_kses()` with allowed tags |

**Security gates (never skip):**
- Nonce check: `check_ajax_referer()` or `wp_verify_nonce()` before any AJAX handler
- Capability check: `current_user_can()` before any privileged operation
- REST permission: always define `permission_callback`, never return `__return_true` in production

**Database:**
- Always use `$wpdb->prepare()` for any query with user input
- Prefix all custom tables with `$wpdb->prefix`
- Use `$wpdb->get_results()` with `ARRAY_A` for predictable output

**Plugin architecture:**
- Main plugin file: single class, `register()` method, loaded via `add_action('plugins_loaded', ...)`
- Singleton pattern with `::get_instance()` is acceptable
- Avoid global variables — use class properties or options API
- Use `plugin_dir_path(__FILE__)` not `__DIR__` for includes

**WooCommerce / HPOS:**
- Never use `$order->post` directly — always use CRUD methods
- Use `wc_get_order()` not `get_post()`
- Update meta via `$order->update_meta_data()` then `$order->save()`

**Before finishing any PHP file:**
1. Run mental WPCS pass — tabs, escaping, sanitization
2. Confirm nonce + capability checks on all AJAX/REST handlers
3. Confirm text domain matches project slug
