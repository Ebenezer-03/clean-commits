# clean-commits

[![License: MIT](https://img.shields.io/badge/license-MIT-blue.svg)](./LICENSE)
[![Format](https://img.shields.io/badge/format-Claude%20Code%20plugin%20%2B%20AGENTS.md-informational)](#installation)

Stop AI coding agents from polluting your commit history. `clean-commits` keeps every commit authored solely by you and every message in [Conventional Commits](https://www.conventionalcommits.org/) format. No `Co-Authored-By: Claude` trailers, no "🤖 Generated with ..." lines, no `feat: phase 1` messages that mean nothing to anyone reading your history later.

It ships two ways from one set of rules: a native **Claude Code plugin**, and a plain **`AGENTS.md`** file for every other agent (Codex, Cursor, Aider, Copilot Workspace, etc.) that reads that convention.

## The problem

Point an AI agent at a repo and let it commit, and you tend to get:

- `Co-Authored-By: Claude <noreply@anthropic.com>` trailers baked into history you didn't ask for
- Commit messages that describe the agent's plan ("phase 1", "phase 2") instead of the actual diff
- Ten unrelated changes squashed into one commit, or one change split across ten
- Work sitting uncommitted and unpushed for an entire session, gone if the session dies

`clean-commits` is a small, boring set of rules that fixes all four.

## What it enforces

- **Solo human authorship.** Every commit is attributed to you, never the agent, and no AI or session attribution appears anywhere in the message or PR body.
- **Conventional Commits.** `feat`, `fix`, `update`, `refactor`, `docs`, `style`, `test`, `perf`, `build`, `ci`, `chore`, chosen from the actual diff, not the task description.
- **One commit per logical change.** A multi-step task produces one commit per concern, not one per plan milestone.
- **Push after every commit.** Nothing valuable is left unpushed if a session is interrupted.

## Installation

### Claude Code

```
/plugin marketplace add Ebenezer-03/clean-commits
/plugin install clean-commits
```

### Any other agent (Codex, Cursor, Aider, etc.)

Copy [`AGENTS.md`](./AGENTS.md) into the root of your project, or merge its contents into an existing `AGENTS.md`. Any tool that reads that file picks up the same rules. No install step required.

## How it works

**First commit in a repo.** The agent checks `git config user.name` and `user.email`. If either is unset, it asks for two things: your email and your GitHub username. It verifies the username with `gh api users/<username>` and writes both values to that repo's local git config only (never `--global`, so other projects on your machine are untouched). If `gh` isn't installed or the lookup fails, it warns and proceeds with what you typed rather than blocking you.

**Every commit after that.** The agent reuses the stored identity, writes a Conventional Commits message describing the diff it just made, checks the message for any AI attribution before running `git commit`, then runs `git push`.

Example of what a single "implement the plan" instruction produces, when the plan spans a login feature, a refactor, and its tests:

```
feat: add email/password login form
refactor: extract validation into shared hook
test: cover login form validation edge cases
```

Not this:

```
feat: phase 1
Co-Authored-By: Claude <noreply@anthropic.com>
```

## Cleaning up existing history

If a repo already has AI-attributed commits:

- **Unpushed, most recent commit:** `git commit --amend` with a corrected message.
- **Older or already-pushed commits:** requires rewriting history (`git rebase -i`, or `git filter-repo` for bulk cleanup). This is destructive to shared history and needs a force-push, so the agent explains the tradeoff and asks for explicit confirmation first.

## Contributing

Issues and pull requests are welcome. Keep changes scoped, and follow the Conventional Commits format above when you submit one.

## License

[MIT](./LICENSE)
