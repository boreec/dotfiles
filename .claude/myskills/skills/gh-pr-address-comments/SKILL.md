---
name: gh-pr-address-comments
description: Use to review and address GitHub PR review comments on the current branch. Fetches actionable review comments (suggestions, blockers, requested changes), analyzes them against PR changes and optional Linear ticket context, and creates a fix plan for valid concerns.
allowed-tools: Bash(gh *), Bash(git *), Read, Grep, Glob, Agent, AskUserQuestion
---

# Address PR Review Comments

## Context

- **Current branch**: !`git branch --show-current`

## Step 0 — Find the PR

Run: `gh pr list --head "{branch from above}" --json number,title,url,body --state open --limit 1`

### Gate 1 — No PR

If no open PR was found (empty array `[]` or error), respond with exactly:

> Can't address comments: no PR found. Are you on the correct branch?

Then **stop**. Do not proceed further.

---

## Step 1 — Fetch Comments

Launch a single Agent (subagent_type: `general-purpose`) to fetch and categorize comments:

> You are analyzing review comments on GitHub PR #{number} in this repository.
>
> 1. Get the repo identifier: `gh repo view --json nameWithOwner -q .nameWithOwner`
> 2. Fetch inline review comments: `gh api "repos/{owner/repo}/pulls/{number}/comments" --paginate`
> 3. Fetch PR reviews (for review-level state like CHANGES_REQUESTED): `gh api "repos/{owner/repo}/pulls/{number}/reviews" --paginate`
> 4. Fetch PR conversation comments: `gh pr view {number} --json comments --jq '.comments'`
>
> **Important**: Discard any resolved comments. For inline review comments, check the `in_reply_to_id` field and thread structure to identify resolved conversations. For the GraphQL approach, you can also check `gh api graphql` with the `isResolved` field on review threads. Only unresolved comments should be considered.
>
> For each unresolved comment, categorize it as:
> - **Actionable**: suggestions, change requests, blockers, nits, any comment from a review with state `CHANGES_REQUESTED`, explicit code improvement requests
> - **Informational**: approvals, thank-you notes, questions without action items, general discussion
>
> Return a structured report with:
> - A list of **actionable comments**, each with: `author`, `file` (if inline), `line` (if inline), `body` (full text), `type` (suggestion/blocker/nit/change-request), `comment_url`
> - A list of **unique authors** who left actionable comments
> - A count of total vs actionable comments

### Gate 2 — No Actionable Comments

If the subagent found **zero actionable comments**, respond with exactly:

> Can't address comments: PR has no actionable comments.

Then **stop**. Do not proceed further.

---

## Step 2 — Reviewer Selection

If actionable comments come from **more than one author**, use `AskUserQuestion` to present a selection:

- **Question**: `"Comments from multiple reviewers were found. Whose would you like to address?"`
- **Options** (build dynamically from the unique authors list):
  1. `"All reviewers"` — description: `"Address all {N} actionable comments"`
  2. One option per unique author — label: `"{author}"`, description: `"{count} actionable comment(s)"`

Filter the actionable comments based on the user's selection.

If there is only one author, skip this menu.

---

## Step 3 — Linear Ticket Detection

Check if the PR title or the current branch name contains a Linear ticket ID (a pattern like `ENG-1234`, `PROJ-42`, i.e. `[A-Z]+-\d+`).

If **no ticket ID was found**, use `AskUserQuestion`:

- **Question**: `"No Linear ticket was detected in the branch name or PR title. Is there a ticket associated with this PR?"`
- **Options**:
  1. `"No ticket"` — description: `"Continue without Linear context"`
  2. `"Yes, let me provide it"` — description: `"I'll enter the ticket ID"`

If the user selects "Yes, let me provide it", they will type the ticket ID via the "Other" option or in their response. Use that ID going forward.

---

## Step 4 — Context Sources

Build a summary of what context will be gathered. The default is to use **all available sources**:
- PR diff (always available)
- Linear ticket context (if a ticket ID is known from Step 3)

Use `AskUserQuestion` to confirm:

- **Question**: Build it dynamically based on available sources. If a ticket ID is known: `"I'll gather context from the PR diff and Linear ticket {TICKET_ID}. Want to adjust?"`. If no ticket: `"I'll gather context from the PR diff. Want to adjust?"`
- **Options**:
  1. `"Proceed" (Recommended)` — description: `"Gather all listed context sources"`
  2. `"Skip PR diff"` — description: `"Don't analyze the diff, only use Linear context"` — **only include if a ticket ID is known** (otherwise skipping the diff would leave no context)
  3. `"Skip Linear ticket"` — description: `"Don't fetch Linear context, only use the PR diff"` — **only include if a ticket ID is known**

Proceed based on the user's choice. If they select "Proceed" or the recommended option, use all available sources.

---

## Step 5 — Parallel Context Gathering

Launch the selected subagents **in a single message** so they run in parallel:

### Subagent B — Diff Analyzer (if "PR diff" selected)

Launch an Agent (subagent_type: `diff-analyzer`) with this task:

> **Mode: PR Diff Analysis**
>
> Analyze the changes in GitHub PR #{number}. Return per-file change summaries and an overall summary of the PR's purpose.

### Subagent C — Linear Ticket Explorer (if "Linear ticket" selected)

Launch an Agent (subagent_type: `general-purpose`) with this task:

> You are gathering context from Linear about ticket {TICKET_ID}.
>
> Use the following MCP tools (these are available to you):
>
> 1. `mcp__plugin_linear_linear__get_issue` — Fetch the ticket details (description, status, assignee, priority, labels)
> 2. `mcp__plugin_linear_linear__list_comments` — Fetch all comments on this ticket
> 3. `mcp__plugin_linear_linear__get_issue_status` — Get the current status
> 4. Check if the ticket has a project. If it does:
>    - `mcp__plugin_linear_linear__get_project` — Get project description, status, target dates
>    - `mcp__plugin_linear_linear__get_status_updates` — Get recent project status updates
> 5. Check if the ticket has related issues. If it does, fetch key details of each related ticket.
>
> Return a structured summary:
> - **Ticket**: ID, title, description, status, priority
> - **Acceptance criteria**: extracted from description if present
> - **Comments**: all comments with author and timestamp
> - **Related tickets**: ID, title, status for each
> - **Project context**: project name, description, recent updates (if applicable)

---

## Step 6 — Analysis

For each actionable comment (filtered from Step 2), analyze it against the gathered context:

1. **Locate the relevant code** in the PR diff (if available). If the comment references a specific file and line, find that exact change.
2. **Understand the reviewer's concern**: What are they asking to change and why?
3. **Cross-reference with Linear context** (if available): Does the current implementation align with the ticket requirements? Does the reviewer's suggestion conflict with or support the acceptance criteria?
4. **Determine a verdict**:
   - **FIX**: The comment identifies a legitimate issue — a bug, a missed edge case, a style violation, a readability improvement, or a valid architectural concern. Describe specifically what needs to change.
   - **SKIP**: The comment is based on a misunderstanding of the code, is already addressed elsewhere in the PR, conflicts with the ticket requirements, or is purely a matter of preference with no meaningful impact. Explain why clearly.

---

## Step 7 — Output

Present the results in this format:

### PR Overview
- **PR**: #{number} — {title}
- **URL**: {url}
- **Linear ticket**: {ticket_id} (if applicable, with one-line summary of requirements)

### Comment Analysis

For each actionable comment, display:

| # | Author | Location | Type | Verdict | Summary |
|---|--------|----------|------|---------|---------|
| 1 | @user  | file.ts:42 | suggestion | FIX | Brief description |
| 2 | @user  | file.ts:78 | blocker | SKIP | Brief description |

Then for each comment, expand with:
- **Comment**: The reviewer's comment (abbreviated if long)
- **Verdict**: FIX or SKIP
- **Rationale**: Why this should or should not be fixed
- **Fix** (if FIX): What specifically needs to change

### Fix Plan

If there are any FIX verdicts, create an ordered implementation plan:
1. Group fixes by file
2. Order by dependency (changes that affect other changes first)
3. Each step should be specific enough to execute immediately
4. Note any fixes that might interact with each other
