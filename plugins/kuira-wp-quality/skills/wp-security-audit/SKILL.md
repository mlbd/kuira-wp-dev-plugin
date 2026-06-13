---
name: wp-security-audit
description: >
  WordPress security audit skill. Triggers proactively after writing
  authentication, nonce verification, REST endpoint registration, AJAX handlers,
  database queries, file upload handling, or user input processing.
  Also triggers on: "audit security", "check vulnerabilities", "is this safe",
  "security review", "OWASP", "SQL injection", "XSS check".
  Delegates heavy scanning to wp-security-auditor subagent.
allowed-tools: Bash, Grep, Glob, Read
model: sonnet
run-in-subagent: true
---

## WordPress Security Audit

Delegate to the `wp-security-auditor` subagent for full scanning. It uses haiku model
for cost-efficient file traversal.

### Critical Checks

**1. Nonce Verification (CSRF)**
```bash
# Find AJAX handlers missing nonce check
grep -rn "wp_ajax_\|wp_ajax_nopriv_" --include="*.php" . | \
  while read line; do
    func=$(echo $line | grep -o 'add_action.*function');
    echo "$line"
  done
```
Every handler must call `check_ajax_referer()` or `wp_verify_nonce()`.

**2. Unsanitized Input**
```bash
grep -rn "\$_POST\|\$_GET\|\$_REQUEST\|\$_SERVER" --include="*.php" . | \
  grep -v "sanitize_\|esc_\|absint\|intval\|wp_verify_nonce\|check_ajax_referer"
```

**3. Direct Database Queries**
```bash
grep -rn "\$wpdb->query\|\$wpdb->get_results\|\$wpdb->get_var" --include="*.php" . | \
  grep -v "prepare("
```
Any `$wpdb` query with variables MUST use `->prepare()`.

**4. Unescaped Output**
```bash
# Direct echo/print of a variable or get_*()
grep -rn "echo \$\|echo get_\|print \$" --include="*.php" . | \
  grep -v "esc_\|wp_kses\|absint\|intval\|esc_attr\|esc_html\|esc_url"

# Request data reaching output anywhere on the line (catches concatenation,
# e.g. `echo 'Saved: ' . $_POST['name']`) — high-signal reflected XSS.
grep -rnE "(echo|print) .*\\\$_(POST|GET|REQUEST|SERVER|COOKIE)" --include="*.php" . | \
  grep -v "esc_\|wp_kses\|absint\|intval"
```
> The second pattern matters: a naive `echo \$` misses output built by
> concatenation, which is where real reflected-XSS bugs hide.

**5. Capability Checks**
```bash
grep -rn "wp_ajax_\|rest_api_init\|admin_post_" --include="*.php" . | \
  grep -v "current_user_can\|permission_callback"
```

**6. File Inclusion**
```bash
grep -rn "include\|require\|include_once\|require_once" --include="*.php" . | \
  grep "\$"
```
Variable-based includes are high risk — flag for manual review.

**7. REST Endpoints**
```bash
grep -rn "register_rest_route" --include="*.php" .
```
Verify every route has `permission_callback` that is NOT `__return_true`.

**8. Dependency vulnerabilities**
```bash
# PHP dependencies (Composer 2.4+)
[ -f composer.lock ] && composer audit --no-interaction 2>&1 | tail -30

# JS dependencies (production only — dev tooling CVEs rarely ship to users)
[ -f package-lock.json ] && npm audit --omit=dev 2>&1 | tail -30
```
Flag any **known-vulnerable** dependency that ships in the plugin zip. Dev-only
tools (phpcs, wp-scripts) that never reach users are INFO, not blockers — focus on
runtime/bundled deps.

### Severity Levels

**CRITICAL (block release):**
- Missing nonce on any state-changing AJAX handler
- `$wpdb` query with unsanitized user input and no `prepare()`
- REST endpoint with `permission_callback => '__return_true'` in production
- File inclusion with user-controlled variable

**WARNING (fix before release):**
- Unescaped output in admin pages
- Missing capability check on privileged operations
- Direct `$_POST` access without sanitization

**INFO (note for improvement):**
- Long functions over 50 lines
- Deprecated WordPress functions
- Missing `isset()` checks before `$_POST` access

### Output Format

```
=== SECURITY AUDIT REPORT ===
Plugin: {plugin-name} v{version}
Date: {date}

CRITICAL (X issues)
---
[C1] {file}:{line} - {description}
     Code: {snippet}
     Fix:  {recommendation}

WARNINGS (X issues)
---
...

CLEAN: {list of areas with no issues}
```
