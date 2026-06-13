# Fixtures — prove the auditors work

These are test inputs for the kuira **security** and **quality** auditors. They let
you (and reviewers) verify the toolkit actually catches what it claims — and they
make a good demo.

- **`vulnerable/vuln-demo.php`** — seven deliberately planted issues, marked `[V1]`–`[V7]`.
- **`clean/clean-demo.php`** — the same code with every issue fixed (`[Vn fixed]`).

> ⚠️ `vulnerable/` is intentionally insecure. Never copy it into a real plugin.

## How to run the demo

In Claude Code, from the toolkit repo:

```
@wp-security-auditor scan fixtures/vulnerable
```

Or invoke the skill: "audit security of fixtures/vulnerable". A correct run reports
**all seven** issues at CRITICAL/WARNING severity. Compare against `clean/` (should
report none).

## Expected detections

| ID | Planted issue | Type | Severity | Caught by |
|----|---------------|------|----------|-----------|
| V1 | AJAX handler with no nonce | CSRF | CRITICAL | `wp-security-audit` (nonce check), `wp-security-auditor` |
| V1 | AJAX handler with no capability check | Privilege escalation | WARNING | `wp-security-audit` (capability check) |
| V2 | `$_POST` written to option unsanitized | Unsanitized input | WARNING | `wp-security-audit` (input scan) |
| V3 | `echo` of `$_POST` data | Reflected XSS | CRITICAL | `wp-security-audit` (unescaped output) |
| V4 | `$_GET` interpolated into `$wpdb` query | SQL injection | CRITICAL | `wp-security-audit` (DB scan, no `prepare`) |
| V5 | REST route `permission_callback => __return_true` | Broken access control | CRITICAL | `wp-security-audit` (REST scan) |
| V6 | Unsanitized REST param in `DELETE` | SQL injection | CRITICAL | `wp-security-audit` (DB scan) |
| V7 | `include` of user-controlled path | LFI / RCE | CRITICAL | `wp-security-audit` (file inclusion scan) |

If a run misses any of these, that's a regression in the auditor — open an issue and
reference the `[Vn]` marker.
