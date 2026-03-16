---
name: remove-installation
description: >
  Comment out or disable a tool installation in this repo's Docker base image Dockerfiles
  by generating the correct COMMENT/COMMENT_BLOCK entries in the config modifications file.
  Use this skill whenever the user wants to remove, disable, comment out, or stop installing
  a specific tool (bower, pnpm, yarn, nuget, mono, etc.) from any base image — scanner,
  controller, remediate, or sast. Trigger on phrases like "remove X from the dockerfile",
  "comment out X", "stop installing X", "disable X in scanner", "I don't want X in the images",
  or "strip X from the base image". Default target is scanner when no target is specified.
---

# remove-installation

Comment out all installation lines for a given tool in one or more Dockerfiles by appending the correct `COMMENT` / `COMMENT_BLOCK` entries to the appropriate modifications config, then validating that exactly the right lines were affected.

**Usage:** `/remove-installation <tool-name> [target]`

**Target** is optional and defaults to `scanner`. Supported values:

| Target | Dockerfiles | Config |
|---|---|---|
| `scanner` *(default)* | `repo-integrations/scanner/Dockerfile` + `Dockerfile.full` | `config/scanner-modifications.txt` |
| `controller` | `repo-integrations/controller/Dockerfile` | `config/controller-modifications.txt` |
| `remediate` | `repo-integrations/remediate/Dockerfile` | `config/remediate-modifications.txt` |
| `sast` | `repo-integrations/scanner/DockerfileSast` | `config/scanner-sast-modifications.txt` |

You can also pass a raw Dockerfile path (e.g. `repo-integrations/scanner/Dockerfile`). Infer the config by matching the path to the table above — if none match, ask the user which config to use.

**Examples:**
- `/remove-installation bower` → scanner (default)
- `/remove-installation bower scanner` → scanner (explicit)
- `/remove-installation pnpm controller` → controller Dockerfile
- `/remove-installation yarn remediate` → remediate Dockerfile
- `/remove-installation nuget repo-integrations/scanner/DockerfileSast` → specific file

---

## Step 1: Resolve targets

```bash
REPO=$(git rev-parse --show-toplevel)
```

Parse `$ARGUMENTS` to extract the tool name and optional target. The target is everything after the first word. If no target is given, use `scanner`.

Resolve the target to a list of Dockerfiles and a config file using the table above. All paths are relative to `$REPO`.

## Step 2: Discover all lines related to the tool

Search all resolved Dockerfiles case-insensitively for the tool name. Use Grep with `-i` and `output_mode: "content"` on each file. Look for:

- `ARG <TOOL>_VERSION=...` lines (uppercase tool name)
- `RUN install-tool <tool>` lines (lowercase tool name)
- Multi-line RUN blocks (lines connected by `\`) that reference the tool — e.g. config files, permissions, env setup
- `ENV` lines that reference the tool name
- Comment headers like `# Install <Tool>` immediately above a RUN block

Also search for tool-specific artifacts by name (e.g. bower has a `.bowerrc` permissions block).

## Step 3: Choose the right action for each line

| Line type | Config action |
|---|---|
| `ARG <TOOL>_VERSION=x.y.z` | `COMMENT:<TOOL>_VERSION` — uppercase, **no version number** (stays valid after Renovate bumps the version) |
| `RUN install-tool <tool>` (single line, no `\`) | `COMMENT:install-tool <tool>` — lowercase tool name |
| Multi-line RUN block where continuation lines share a unique string | `COMMENT:<unique-string>` with literal dots escaped as `\.` |
| `ENV <VAR>=...` that is tool-specific | `COMMENT:<VAR>` |
| `# Install <Tool>` comment header above a `\`-continued multi-line RUN | `COMMENT_BLOCK:Install <Tool>` — only if ALL lines of the block are connected by `\` |

**Rules:**

- `COMMENT_BLOCK` only extends across lines connected by `\`. `ARG` and `RUN` are separate Docker commands — never use a single `COMMENT_BLOCK` for both; always use separate `COMMENT` entries.
- For `ARG` lines: use `COMMENT:<TOOL>_VERSION` (uppercase, no `=x.y.z`) so the pattern remains valid after future version bumps.
- Escape literal dots in patterns as `\.` (e.g. `.bowerrc` → `\.bowerrc`).
- Use `COMMENT` (not `COMMENT_BLOCK`) for single-line RUN commands.
- CVE comment tables (the `┌──┬──┐` blocks) are already comments — do not add patterns targeting them.

## Step 4: Check for duplicates

Read the resolved config file in full before appending. For each pattern you plan to add, check for an exact string match. Skip any pattern already present and note it in the report.

## Step 5: Append to config

Add a clearly labelled section to the resolved config file:

```text
# Comment out <tool> installation
COMMENT:<TOOL>_VERSION
COMMENT:install-tool <tool>
# ... any additional patterns for related blocks
```

Leave a blank line before the new section for readability.

## Step 6: Validate precision

Create a temporary modifications file with **only the new patterns** (not the full config). Apply it to a temp copy of **each resolved Dockerfile** and diff against the original. Show every diff.

```bash
cat > /tmp/new-mods.txt << 'EOF'
<new patterns here>
EOF

# Repeat for each resolved Dockerfile:
cp $REPO/<dockerfile-path> /tmp/df-test.txt
$REPO/bin/modify-dockerfile.sh /tmp/df-test.txt /tmp/new-mods.txt
diff $REPO/<dockerfile-path> /tmp/df-test.txt
```

Inspect every diff:
- Every changed line must relate to the target tool.
- No unrelated lines must have changed.
- If a line was already commented in a given Dockerfile, the diff for that file may show no change for that pattern — that is expected and correct.

## Step 7: Report

Summarise:
- Each pattern added to the config (with exact text).
- For each Dockerfile: which lines were commented (line numbers and content).
- Confirmation that patterns are version-agnostic.
- Anything intentionally left unchanged (e.g. CVE comment tables).
- Any patterns skipped because they already existed in the config.

---

## Reference example: bower

Bower appears in both scanner Dockerfiles as:
- `ARG BOWER_VERSION=1.8.14` → `COMMENT:BOWER_VERSION`
- `RUN install-tool bower` → `COMMENT:install-tool bower`
- A two-line `\`-continued RUN block writing `.bowerrc` and chowning it → `COMMENT:\.bowerrc`

Both continuation lines of the bowerrc block contain `.bowerrc`, so one pattern covers the full block. Dots must be escaped.

Resulting config entries:
```text
# Comment out bower installation
COMMENT:BOWER_VERSION
COMMENT:install-tool bower
COMMENT:\.bowerrc
```
