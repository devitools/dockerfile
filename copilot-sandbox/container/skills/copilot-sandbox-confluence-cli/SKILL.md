---
name: copilot-sandbox-confluence-cli
description: Manage Confluence pages from the command line using the `confluence` script available inside the container. Use when asked to list, search, get, create, update, or delete Confluence pages. Also use when publishing documentation, runbooks, or Markdown files to Confluence spaces.
---

# Confluence CLI

`/usr/local/bin/confluence` — Confluence Cloud REST API client.

## Authentication

Preferred: shared Atlassian vars (set once, all Atlassian tools use them):

```bash
export ATLASSIAN_URL="https://picpay.atlassian.net"
export ATLASSIAN_EMAIL="your-email@picpay.com"
export ATLASSIAN_API_TOKEN="your-api-token"
```

Override with Confluence-specific vars if needed: `CONFLUENCE_URL`, `CONFLUENCE_EMAIL`, `CONFLUENCE_API_TOKEN`.

> The script appends `/wiki/rest/api` to the base URL automatically.

Token: https://id.atlassian.com/manage-profile/security/api-tokens

## Commands

```
confluence list <SPACE> [LIMIT]              # list pages in space
confluence search <QUERY> [SPACE] [LIMIT]    # search pages
confluence get <PAGE_ID> [--content]         # get page (+ content)
confluence create <SPACE> <TITLE> [OPTIONS]  # create page
confluence update <PAGE_ID> [OPTIONS]        # update page
confluence delete <PAGE_ID> [--confirm]      # delete page
```

### Options for `create` and `update`

```
--content TEXT       inline text content
--file FILE          read content from file
--markdown           convert Markdown to Confluence format
--parent PAGE_ID     create as child page (create only)
--title TEXT         new title (update only)
```

## Quick examples

```bash
confluence list DEV
confluence search "deploy runbook" DEV
confluence get 123456789 --content

# Publish Markdown file
confluence create DEV "Deploy Runbook" --file runbook.md --markdown

# Create as child page
confluence create DEV "Subtopic" --file sub.md --markdown --parent 123456789

# Update and delete
confluence update 123456789 --file updated.md --markdown
confluence delete 123456789 --confirm
```

## Requirements

`curl`, `jq`
