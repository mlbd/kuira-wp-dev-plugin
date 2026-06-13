---
name: oasis-workflow
description: >
  Oasis Workflow Pro development patterns. Auto-triggers on any file inside
  oasis-workflow-pro/, ow-pro/, or oasiswf/ directories. Also triggers on:
  "editorial workflow", "sign-off", "workflow step", "action history",
  "workflow inbox", "oasis", "OW", "workflow-complete", "get-inbox".
  Provides known bug patterns, REST API quirks, and data model context.
allowed-tools: Read, Bash, Grep, Glob
paths:
  - "**/oasis-workflow*/**"
  - "**/ow-pro*/**"
  - "**/oasiswf*/**"
---

## Oasis Workflow Pro — Development Context

**Text domain:** `oasiswf`
**Main constant:** `OW_PLUGIN_VERSION`, `OW_PLUGIN_DIR`, `OW_PLUGIN_URL`
**REST namespace:** `oasiswf/v1`

### Known Bugs / Quirks

**sign-off ability bug (confirmed):**
The `sign-off` REST ability returns `{ success: true, action_history_id: 0 }` but does NOT persist state.
→ Use `workflow-complete` as the reliable alternative for final step transitions.
→ Never report `sign-off` as working until this is verified fixed in the current version.

**get-inbox requires explicit user_id:**
`GET /oasiswf/v1/get-inbox` silently returns empty if `user_id` parameter is omitted.
→ Always pass `user_id` explicitly. Do not rely on the current user being inferred.

### Data Model

**Workflow tables:**
- `{prefix}fc_workflows` — workflow definitions
- `{prefix}fc_workflow_steps` — step definitions
- `{prefix}fc_action_history` — execution log (key for debugging)
- `{prefix}fc_email_settings` — notification config

**Key action_history columns:**
- `action_status` — `assignment` | `complete` | `abort`
- `step_id` — references `fc_workflow_steps`
- `assigned_to_user_id` — current assignee
- `action_date` — timestamp

### REST API Patterns

**Standard ability call:**
```php
// Always validate ability_id exists before calling
$ability = OW_Utility::get_instance()->get_ability_by_id( $ability_id );
if ( ! $ability ) {
    wp_send_json_error( array( 'message' => 'Invalid ability.' ) );
    return;
}
```

**Inbox query (correct pattern):**
```php
$args = array(
    'user_id'    => get_current_user_id(), // required
    'post_type'  => 'post',
    'per_page'   => 20,
    'paged'      => 1,
);
$inbox_items = OW_Process_Flow::get_instance()->get_inbox_items( $args );
```

### Workflow States

```
draft → in_workflow → [sign_off step] → workflow_complete
                    ↘ abort ↙
```

**action_status values:**
- `assignment` — post is assigned to a user in a workflow step
- `complete` — step completed (use `workflow-complete` ability)
- `abort` — workflow aborted

### Hook Naming Convention

```php
// Actions
do_action( 'oasiswf_before_step_complete', $step_id, $post_id, $user_id );
do_action( 'oasiswf_after_workflow_complete', $post_id, $workflow_id );

// Filters
apply_filters( 'oasiswf_inbox_query_args', $args );
apply_filters( 'oasiswf_step_assignees', $assignees, $step_id );
```

### Debugging Checklist

When a workflow action doesn't behave as expected:
1. Check `fc_action_history` — is a row being inserted?
2. Verify `action_status` value — is it `assignment` when you expect `complete`?
3. Check `action_history_id` in REST response — if `0`, the operation silently failed
4. Confirm `user_id` matches `assigned_to_user_id` in the history row
5. Check nonce is fresh — stale nonces cause silent failures in WP AJAX
