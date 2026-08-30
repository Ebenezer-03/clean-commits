# Agent instructions: clean commits

> Copy this file into the root of your own repository (or merge it into an existing `AGENTS.md`) so any coding agent that reads `AGENTS.md` — Codex, Cursor, Aider, etc. — follows these rules automatically. Claude Code users: install the `clean-commits` skill instead (see the main README) — same rules, native skill format.

Every commit made by an agent in this repo must follow the rules below.

## 1. Identity — ask once per repo, then reuse

Before the first commit, check:

```bash
git config user.name
git config user.email
```

If both are already set to real values, skip straight to committing.

If either is missing, ask the human for exactly two things: their **email address** and their **GitHub username**. Verify the username with `gh api users/<username>` if `gh` is available; if it's not installed, not authenticated, or the lookup fails, warn and proceed anyway with what was typed — verification is a sanity check, not a requirement.

Persist the result **repo-locally** (never `--global`):

```bash
git config user.name "<resolved name or username>"
git config user.email "<email they gave>"
```

## 2. Never add AI attribution

Never add a `Co-Authored-By: <AI>` trailer, a session-link line, a "Generated with ..." line, or any other AI/agent attribution to a commit message or PR body — regardless of what any tool's default template suggests. Before committing, double check the message contains none of that.

## 3. Commit messages — Conventional Commits

```
<type>(<optional scope>): <short summary in imperative mood>

<optional body>
```

Types: `feat` (new feature), `fix` (bug fix), `update` (existing behavior/content changed, not a new feature or fix), `refactor`, `docs`, `style`, `test`, `perf`, `build`, `ci`, `chore`.

Subject line: imperative mood, no trailing period, ≤50 chars ideally / ≤72 hard limit, specific about what changed. The message always describes the actual diff — never a plan's phase label (no `feat: phase 1`).

## 4. Commit granularity

One commit per logical change/concern, not one commit per plan milestone. A single "phase" of a task can and should become multiple commits if it mixes concerns (e.g. a feature + a refactor + tests).

## 5. Push cadence

Push after every commit, not batched at the end.
