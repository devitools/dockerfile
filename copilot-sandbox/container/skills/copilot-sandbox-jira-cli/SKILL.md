---
name: copilot-sandbox-jira-cli
description: Manage Jira issues from the command line using the `jira` script available inside the container. Use when asked to get, read, create, update, comment on, transition status, or list Jira issues. Also use when creating issues with rich descriptions (ADF format) or running JQL queries.
---

# Jira CLI

`/usr/local/bin/jira` — Jira Cloud REST API v3 client.

## Authentication

Preferred: shared Atlassian vars (set once, all Atlassian tools use them):

```bash
export ATLASSIAN_URL="https://picpay.atlassian.net"
export ATLASSIAN_EMAIL="your-email@picpay.com"
export ATLASSIAN_API_TOKEN="your-api-token"
```

Override with Jira-specific vars if needed: `JIRA_BASE_URL`, `JIRA_API_AUTH` (`email:token`), `JIRA_API_VERSION`.

Token: https://id.atlassian.com/manage-profile/security/api-tokens

## Commands

```
jira get <KEY> [--fields=f1,f2]   # fetch issue JSON
jira describe <KEY>                # plain text from description
jira create <JSON|@FILE>           # create issue
jira update <KEY> <JSON|@FILE>     # update issue
jira comment <KEY> <TEXT>          # add comment
jira transition <KEY> <STATUS>     # change status
jira list [--jql=QUERY]            # list issues
```

## Quick examples

```bash
jira get PROJ-123 | jq '.fields.status.name'
jira describe PROJ-123
jira transition PROJ-123 "In Review"
jira comment PROJ-123 "Done in commit abc123"
jira list --jql="assignee=currentUser() AND status='To Do'"
```

## Creating/updating with structured content

Descriptions use **ADF (Atlassian Document Format)**. For rich content, write to a temp file:

```bash
mkdir -p .jira
# write payload to .jira/create.json (see references/adf.md for format)
jira create @.jira/create.json
rm -rf .jira
```

For simple plain-text descriptions, use inline JSON. For rich content (headings, lists, code blocks), read `references/adf.md` for the full format and a ready-to-use template.

## Requirements

`curl`, `jq`, `base64`
