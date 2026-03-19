---
name: comply-with-cicd-and-pre-commit-hooks
description: Discover and list all required validation steps (linting, testing, type-checking, formatting, etc.) that the current branch must pass before merge. Checks GitHub Actions workflows (.github/workflows/*.yml) and local git hooks (lefthook, pre-commit, husky). Use when preparing to push, before creating a PR, when CI fails and you need to understand what checks run, or when the user asks "what checks do I need to pass".
allowed-tools: Bash, Read, Grep, Glob, Agent, AskUserQuestion, Edit, Write
---

# Comply with CI/CD and Pre-Commit Hooks

## Context

- **Current branch**: !`git branch --show-current`
- **Repo root**: !`git rev-parse --show-toplevel`

## Step 0 — Verify Git Repository

The Context section above already runs `git rev-parse --show-toplevel` and `git branch --show-current` via `!` substitution. If either value is empty or shows an error, respond with exactly:

> Not inside a git repository. Navigate to a project directory first.

Then **stop**. Do not re-run these commands — they were already executed at skill load time.

---

## Step 1 — Parallel Discovery

Steps 1A and 1B have no dependencies on each other. Launch both as subagents **in a single message** so they run in parallel.

### Subagent A — Discover CI/CD Workflows

Launch an Agent (subagent_type: `Explore`) with this task:

> You are analyzing GitHub Actions workflows for the repository at {repo root}, on branch `{current branch}`.
>
> 1. Search for workflow files: `Glob: .github/workflows/*.yml` and `Glob: .github/workflows/*.yaml`
> 2. For **each workflow file found**, read its full content and extract:
>    - **Trigger conditions** (`on:` block) — identify which branches this workflow applies to:
>      - `push.branches` / `push.branches-ignore`
>      - `pull_request.branches` / `pull_request.branches-ignore`
>      - `merge_group`
>      - `workflow_dispatch`
>      - If the workflow uses glob patterns (e.g. `main`, `release/**`, `feature/*`), evaluate whether the current branch matches
>    - **Jobs** — for each job in `jobs:`:
>      - Job name and `runs-on`
>      - The `steps` list: extract each step's `name` (or `uses` action) and `run` command
>      - Conditional expressions (`if:`) that might skip steps
>      - Matrix strategies that multiply steps
>    - **Required status checks** — note any job that appears to be a "gate" (e.g. named `required`, `ci`, `build`, or referenced in branch protection)
>
> **Filter by current branch**: Only report workflows whose trigger conditions match `{current branch}`. If a workflow triggers on `push: branches: [main]` and the current branch is `feat/foo`, mark it as **not applicable to push** but note if it triggers on `pull_request` targeting `main`.
>
> Categorize each applicable workflow as:
> - **On push**: runs when commits are pushed to this branch
> - **On PR**: runs when a PR is opened/updated targeting a base branch
> - **On both**: triggers on both push and PR events
>
> Return a structured report with: workflow filename, workflow name, trigger category (push/PR/both), and for each job: name, runs-on, steps with commands, conditionals, and matrix info.

### Subagent B — Discover Local Git Hooks

Launch an Agent (subagent_type: `Explore`) with this task:

> You are analyzing local git hook configurations for the repository at {repo root}.
>
> Search for and parse **all** of the following that exist:
>
> **Lefthook**: `lefthook.yml`, `lefthook.yaml`, `.lefthook.yml`, `.lefthook.yaml`
> If found, extract: `pre-commit`, `pre-push`, `commit-msg` hooks — each command name, `run` script, `glob`/`files` filters, `tags`, `skip` conditions, `exclude_tags`.
>
> **pre-commit framework**: `.pre-commit-config.yaml`, `.pre-commit-config.yml`
> If found, extract: each `repo` and its `hooks` list — `id`, `name`, `language`, `entry`, `types`/`files` filters, `stages`, default stages.
>
> **Husky**: `.husky/pre-commit`, `.husky/pre-push`, `.husky/commit-msg`, `.husky/_/husky.sh`
> If found, read each hook script and extract the commands.
>
> **Raw git hooks**: `.git/hooks/pre-commit`, `.git/hooks/pre-push`, `.git/hooks/commit-msg`
> If found (and not sample files), read and extract the commands.
>
> **Package.json scripts**: Check if `package.json` exists. If so, look for `lint-staged` config (inline or `.lintstagedrc`) and `scripts` referenced by hook tools.
>
> Return a structured report grouped by stage (pre-commit, pre-push, commit-msg), with each check's: command, description, source file, and any file filters.

---

## Step 2 — Scope Selection

### Detect Changed Files

Launch an Agent (subagent_type: `diff-analyzer`) with this task:

> **Mode: Changed Files Detection**
>
> Detect all files changed since the last push on the current branch. Return the total count, files grouped by extension with counts, and the full deduplicated file list.

### Ask User

Use `AskUserQuestion` to present the scope choice:

- **Question**: `"Found {N} changed files ({summary of types, e.g. '12 .ts, 3 .json, 1 .yml'}). Run all checks or only those relevant to changed files?"`
- **Options**:
  1. `"Changed files only" (Recommended)` — description: `"Only run checks relevant to files changed since last push (e.g. skip TypeScript linting if no .ts files changed)"`
  2. `"All checks"` — description: `"Run every discovered check regardless of changed files"`

### File-Relevance Rules

If the user selects **"Changed files only"**, apply these rules when building the validation map in Step 3:

For each discovered check, determine which file types it targets. Use explicit file filters from the hook/CI config when available (e.g. lefthook `glob: "**/*.ts"`, pre-commit `types: [python]`, CI step with `paths:` filter). When no explicit filter exists, infer from the tool:

| Tool | Relevant extensions |
|------|-------------------|
| `eslint` | `.js`, `.jsx`, `.ts`, `.tsx`, `.mjs`, `.cjs` |
| `prettier` | `.js`, `.jsx`, `.ts`, `.tsx`, `.css`, `.scss`, `.json`, `.md`, `.yml`, `.yaml`, `.html` |
| `tsc` / `tsc --noEmit` | `.ts`, `.tsx` |
| `black` / `ruff` / `flake8` / `pylint` / `mypy` | `.py` |
| `go vet` / `golangci-lint` | `.go` |
| `rubocop` | `.rb` |
| `cargo clippy` / `cargo fmt` | `.rs` |
| `jest` / `vitest` / `pytest` / `go test` | Infer from test file presence in changed files |
| `terraform validate` / `tflint` | `.tf` |

**A check is relevant** if at least one changed file matches its target extensions or file filters. **A check with no determinable file scope** (e.g. a generic build step, `docker build`, or a test suite that could test anything) is **always included** — do not skip it.

---

## Step 3 — Build Raw Validation Map

Collect all discovered checks from Subagent A (CI/CD) and Subagent B (hooks) into a single raw list. If the user selected "Changed files only" in Step 2, **exclude checks that have no matching changed files**.

For each check, record:
- **Check name**: human-readable description (e.g. "Linting", "Unit tests", "Type checking", "Formatting")
- **Tool/Command**: the actual command or action being run
- **Trigger**: when it runs (pre-commit, pre-push, CI on push, CI on PR)
- **Source**: which config file defines it
- **Applies to branch**: whether the current branch matches the trigger conditions
- **Relevant files**: which changed files triggered inclusion of this check (if in "Changed files only" mode)

---

## Step 4 — Deduplicate Checks

CI workflows and local hooks often run the same underlying tool. Running a check twice wastes time and produces duplicate errors. Reduce the raw list into a deduplicated set.

### Merge rules

Two checks are **duplicates** if they invoke the same underlying tool on the same (or overlapping) file scope. Compare by normalizing the command:

| Same tool, different invocations | Merge into |
|---|---|
| lefthook runs `eslint {staged_files}` + CI runs `npx eslint .` | Single `eslint` check — use the broader CI command |
| pre-commit runs `black --check` + CI runs `black --check --diff` | Single `black` check — use whichever has stricter flags |
| lefthook runs `pytest tests/unit` + CI runs `pytest` | Single `pytest` check — use the broader CI command |
| pre-commit runs `prettier --check` + CI runs `prettier --check` | Single `prettier` check |

### How to detect duplicates

1. **Extract the base tool** from each command by stripping: path prefixes (`npx`, `bunx`, `pnpm exec`, `poetry run`, `bundle exec`), flags, and file arguments. E.g. `npx eslint --fix .` → `eslint`, `poetry run pytest tests/` → `pytest`.
2. **Group checks by base tool**.
3. Within each group, pick **one canonical command** to run:
   - Prefer the **broader scope** (whole project over staged-only) since we want to validate what CI will see.
   - Prefer the **stricter flags** (e.g. `--check` over no flag, `--noEmit` over default).
   - If one command is a strict superset of another (same tool, same flags, wider file scope), keep only the superset.
   - If the commands target **disjoint file scopes** (e.g. `eslint src/` vs `eslint scripts/`), keep both — they are not duplicates.
4. For the kept check, **merge the sources** so the output shows all origins (e.g. `lefthook + .github/workflows/ci.yml`).

### Output

Produce a deduplicated validation map:

| # | Check | Tool/Command | Sources | Relevant Files | Deduplicated From |
|---|-------|-------------|---------|----------------|-------------------|
| 1 | Linting | `eslint .` | lefthook + `ci.yml` | `src/app.ts`, `lib/utils.ts` | lefthook `eslint {staged}`, CI `npx eslint .` |
| 2 | Type check | `tsc --noEmit` | `ci.yml` | `src/app.ts` | _(no duplicate)_ |
| ... | ... | ... | ... | ... | ... |

If no duplicates were found, note that and proceed with the original list unchanged.

---

## Step 5 — Output

Present the results in this format:

### Branch Info

- **Current branch**: `{branch}`
- **Likely PR target**: `{main or master or develop — infer from workflow triggers}`

### Pre-Commit / Pre-Push Hooks

List all local hook checks, grouped by stage:

**Pre-commit:**
1. `{command}` — {description} _(source: {file})_
2. ...

**Pre-push:**
1. `{command}` — {description} _(source: {file})_
2. ...

If no local hooks are configured, state: _"No local git hooks detected."_

### CI/CD Checks (on push to this branch)

For each applicable workflow:
- **Workflow**: `{filename}` — `{workflow name}`
- **Jobs**:
  1. `{job-name}`: {steps summary}

If no workflows match push to this branch, state: _"No CI workflows trigger on push to this branch."_

### CI/CD Checks (on PR targeting base branch)

Same format as above, for PR-triggered workflows.

### Quick Compliance Checklist

Generate a checklist the developer can run locally to pre-validate before pushing:

```
[ ] {command_1}  — {what it checks}
[ ] {command_2}  — {what it checks}
...
```

If the user selected "Changed files only", only include checks with matching files. Order by priority: integration tests → unit tests → linting → type-checking → formatting → build.

**When in doubt, include the check.** Only exclude a check if it is **provably impossible** to run locally. The fix loop (Step 7) will handle checks that fail at runtime.

A check is **provably CI-only** if it matches ANY of these:
- It is a GitHub Actions action with no local equivalent (e.g. `actions/upload-artifact`, `actions/deploy-pages`, `codecov/codecov-action`, `github/codeql-action`)
- It is a deployment step (e.g. `kubectl apply`, `aws ecs update-service`, `gcloud run deploy`, `helm upgrade`)
- Its `run` command exclusively reads GitHub Actions context variables with no fallback (e.g. `${{ github.event.pull_request.number }}`, `${{ github.sha }}`)

A check is **NOT CI-only** just because:
- The CI job sets `${{ secrets.* }}` environment variables — the test code may not actually use them, or may have fallback defaults
- It has "integration" in the name — integration tests are commonly runnable locally via Docker/testcontainers
- It references external services — tests often mock or containerize these (e.g. LocalStack for AWS, testcontainers for databases)
- It runs in a Docker container in CI — the same command likely works locally

### Skipped Checks (Changed Files Mode Only)

If the user selected "Changed files only", list checks that were excluded:

| Check | Tool | Reason Skipped |
|-------|------|---------------|
| Python linting | `ruff check .` | No `.py` files changed |
| ... | ... | ... |

If no checks were skipped, omit this section.

---

## Step 6 — Confirm Fix Mode

Use `AskUserQuestion` to ask the user whether to proceed with fixing:

- **Question**: `"Would you like me to run the checks and fix all failures until everything passes?"`
- **Options**:
  1. `"Fix all"` — description: `"Run each check, fix failures, and repeat until all green"`
  2. `"Review only"` — description: `"Stop here — I'll handle the fixes myself"`

If the user selects **"Review only"**, **stop**. The output from Step 5 is the final deliverable.

If the user selects **"Fix all"**, proceed to Step 7.

---

## Step 7 — Run and Fix Loop

Execute each check from the Quick Compliance Checklist (Step 5) in priority order: integration tests, unit tests, linting, type-checking, formatting, build.

### For each check, pick the fast path:

#### Fast path — Auto-fixable tools

If the check has an auto-fix mode, **skip the initial check-mode run** and go straight to fix mode. This avoids running the tool twice (once to report, once to fix):

| Tool | Fix command | Verify command |
|------|-----------|----------------|
| `eslint` | `eslint --fix .` | `eslint .` |
| `prettier` | `prettier --write .` | `prettier --check .` |
| `ruff` | `ruff check --fix . && ruff format .` | `ruff check . && ruff format --check .` |
| `black` | `black .` | `black --check .` |
| `gofmt` | `gofmt -w .` | `gofmt -l .` (empty = pass) |
| `goimports` | `goimports -w .` | `goimports -l .` (empty = pass) |
| `cargo fmt` | `cargo fmt` | `cargo fmt --check` |
| `rubocop` | `rubocop -A` | `rubocop` |

Sequence: run fix command → run verify command → if verify passes, done. If verify still fails, fall back to manual-fix path below.

#### Standard path — Manual-fix checks

For checks without auto-fix (tests, type-checking, build):

1. **Run the command** using Bash. Capture both stdout and stderr.
2. **If it passes** (exit code 0): mark as green, move to next check.
3. **If it fails** (non-zero exit code):
   a. Read the error output. Identify which files and lines have issues.
   b. Read the affected source files to understand context.
   c. Fix using Edit (prefer Edit over Write to minimize diff size).
   d. **Re-run the same check** to verify.
   e. If still failing, repeat from (a).

#### Guardrail — Repeated failure on a single check

If the **same check fails 4 times in a row** (across both auto-fix and manual-fix attempts combined), **stop attempting** and use `AskUserQuestion`:

- **Question**: `"'{check name}' has failed 4 times in a row. Here's why:\n\n{concise summary of the last error output — key error messages, affected files, and what was tried each attempt}.\n\nHow would you like to proceed?"`
- **Options**:
  1. `"Keep trying"` — description: `"Let me make another round of attempts (resets the counter to 0)"`
  2. `"Skip this check"` — description: `"Move on to the next check and flag this one as unresolved"`
  3. `"Stop fixing"` — description: `"Stop the fix loop entirely — I'll take it from here"`

If the user selects **"Keep trying"**, reset the failure counter for this check and resume from step 3a. If **"Skip this check"**, flag it and proceed to the next check. If **"Stop fixing"**, **stop** the entire fix loop and present the current status summary (same format as the Output section below).

### Final verification pass

Once every check has been addressed (passed or flagged), do a **final verification pass**. Run **independent checks in parallel** to save time:

- **Parallel group 1**: linting, type-checking, formatting (these are read-only checks that don't affect each other's output)
- **Sequential after group 1**: tests (unit, integration) — run after because fixes from group 1 may affect test outcomes
- **Sequential last**: build — depends on everything above

If the final pass surfaces new failures, fix them following the same loop (the 4-failure guardrail applies here too). If a second full pass is still not all green, **stop** and report the remaining failures to the user.

### Output

Present a summary:

```
Check                  Status
─────────────────────  ──────
Integration tests      PASS
Unit tests             PASS
Linting                PASS (auto-fixed 3 issues)
Type checking          PASS
Formatting             PASS (auto-fixed 12 files)
Build                  PASS

All checks passing.
```

For any check that was skipped via the guardrail prompt, show:

```
Check                  Status
─────────────────────  ──────
Unit tests             SKIPPED (user chose to skip after 4 failures)
  → Last errors:
    - test/auth.test.ts:42 — TypeError: cannot read property 'id' of undefined
    - test/auth.test.ts:87 — expected 200 but got 401
```
