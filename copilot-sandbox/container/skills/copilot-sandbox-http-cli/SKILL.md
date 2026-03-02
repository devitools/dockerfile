---
name: copilot-sandbox-http-cli
description: Make HTTP requests from the command line using the `http` script available inside the container. Use when testing REST APIs, sending requests with custom headers, handling authentication, or when a more readable alternative to raw curl is needed.
---

# HTTP CLI Tool

`/usr/local/bin/http` — `curl` wrapper with colorized output and automatic JSON formatting.

## Syntax

```bash
http [METHOD] <URL> [KEY=VALUE...] [curl-options]
```

Method is case-insensitive. Defaults to `GET` if omitted.

## Configuration commands

```
http configure                     # set up auth/config interactively
http login                         # authenticate with a service
http set-header NAME VALUE         # persist a header across requests
http remove-header NAME            # remove a persisted header
```

## Environment variables

```bash
HTTP_VERBOSE=1    # show request/response headers
HTTP_TIMEOUT=30   # timeout in seconds
```

## Project config file (`.http.conf`)

```bash
host=https://api.example.com
--header "Authorization: Bearer your-token"
--timeout 30
```

## Examples

```bash
# GET
http get https://api.github.com/users/octocat

# POST with key=value
http post https://httpbin.org/post name=John age=30

# Custom header
http get https://api.example.com/data Authorization:"Bearer ghp_token"

# API key header
http get https://api.example.com/data X-API-Key:"your-key"

# File upload
http post https://api.example.com/upload --form file=@image.jpg

# Pipe JSON to jq
http get https://api.example.com/users | jq '.[0].name'

# Verbose (shows headers)
HTTP_VERBOSE=1 http get https://api.example.com/status
```

## Requirements

`curl`
