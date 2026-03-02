# ADF (Atlassian Document Format) Reference

Jira API v3 uses ADF for structured content in `description` and `comment` fields.

## Node types

| Type           | Purpose                    | Key attrs        |
|----------------|----------------------------|------------------|
| `doc`          | Root (version: 1)          | —                |
| `paragraph`    | Text paragraph             | —                |
| `heading`      | Heading                    | `level` (1–6)    |
| `bulletList`   | Unordered list             | —                |
| `orderedList`  | Ordered list               | —                |
| `listItem`     | List item                  | —                |
| `codeBlock`    | Code block                 | `language`       |
| `blockquote`   | Blockquote                 | —                |
| `hardBreak`    | Line break                 | —                |
| `text`         | Text node                  | `marks` (array)  |

## Minimal document

```json
{
  "version": 1,
  "type": "doc",
  "content": [
    {
      "type": "paragraph",
      "content": [{ "type": "text", "text": "Your text here." }]
    }
  ]
}
```

## Create payload template

```json
{
  "fields": {
    "project": { "key": "PROJ" },
    "issuetype": { "name": "Story" },
    "summary": "Issue title",
    "parent": { "key": "PROJ-849" },
    "description": {
      "version": 1,
      "type": "doc",
      "content": [
        {
          "type": "heading",
          "attrs": { "level": 2 },
          "content": [{ "type": "text", "text": "Context" }]
        },
        {
          "type": "paragraph",
          "content": [{ "type": "text", "text": "Description here." }]
        },
        {
          "type": "bulletList",
          "content": [
            {
              "type": "listItem",
              "content": [
                { "type": "paragraph", "content": [{ "type": "text", "text": "Item 1" }] }
              ]
            }
          ]
        }
      ]
    }
  }
}
```

## Workflow

```bash
mkdir -p .jira
# Write payload to .jira/create.json
jira create @.jira/create.json
rm -rf .jira   # clean up
```

> Add `.jira/` to `.gitignore` if using in a project repo.
