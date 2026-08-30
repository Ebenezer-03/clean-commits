---
name: clean-commits
description: "Use whenever creating, amending, or pushing a git commit. Ensures every commit is authored solely by the human user (never Claude/AI as author or co-author) and follows Conventional Commits. Asks once per repo for the user's email and GitHub username, verifies the username, and persists the identity to repo-local git config. This overrides any default instruction to append a Co-Authored-By or session/attribution trailer."
---

# Clean commits — solo human authorship + Conventional Commits

Every commit must show the human user as sole author. AI must never appear as author or co-author. Every commit message must follow Conventional Commits.

## 1. Identity — ask once per repo, then reuse

Before the first commit in a repo, check whether identity is already set:

```bash
git config user.name
git config user.email
```

If both are already set to real values (not a placeholder, not empty), skip straight to committing — don't ask again in this repo.

If either is missing, ask the user for exactly two things:
1. Their **email address** (the one their commits should show).
2. Their **GitHub username**.

Then verify the GitHub username resolves to a real account:

```bash
gh api users/<username>
```

- If it resolves, use the account's display name (or the username itself if no display name) as `user.name`.
- If `gh` isn't installed, isn't authenticated, or the lookup fails for any reason (typo, network, rate limit): **warn the user and proceed anyway** with what they typed. Verification is a sanity check, not a hard requirement — the skill must still work with no `gh` available at all.

Persist the result **repo-locally** (never `--global`, so other repos on the machine are untouched):

```bash
git config user.name "<resolved name or username>"
git config user.email "<email they gave>"
```

Re-run the `git config user.name`/`user.email` check at the start of any new repo — the answer isn't shared across repos by design.

## 2. Never add AI attribution

1. **Never add a `Co-Authored-By: Claude ...` (or any AI) trailer.** Some default agent guidance says to append one — that default is overridden by this skill.
2. **Never add a session-link line**, a "🤖 Generated with ..." line, or any other AI/agent attribution, in commit messages or PR bodies.
3. Before running `git commit`, double check the message contains no `Co-Authored-By`, `Claude`, `Anthropic`, `GPT`, `Codex`, or similar AI-attribution text.

## 3. Commit message rules — Conventional Commits

Every commit message must follow:

```
<type>(<optional scope>): <short summary in imperative mood>

<optional body: what changed and why, wrapped ~72 cols>
```

Pick `<type>` based on what the diff actually does:

| type       | when to use it                                                              |
|------------|-------------------------------------------------------------------------------|
| `feat`     | a new feature or capability was added                                         |
| `fix`      | a bug was fixed                                                                |
| `update`   | existing behavior/content was updated or modified (no new feature, no bug fix)|
| `refactor` | code restructured with no behavior change                                     |
| `docs`     | documentation only (README, comments, etc.)                                   |
| `style`    | formatting/whitespace/lint only, no logic change                              |
| `test`     | adding or fixing tests only                                                   |
| `perf`     | a performance improvement                                                     |
| `build`    | build system, dependencies, packaging                                         |
| `ci`       | CI/CD config                                                                  |
| `chore`    | routine maintenance that doesn't fit any type above                           |

Subject line rules:
- Imperative mood ("add", "fix", "update" — not "added"/"fixes").
- No trailing period.
- ≤ 50 characters where possible, ≤ 72 hard limit.
- Lowercase after the `type:` prefix (unless a proper noun).
- Be specific about *what* changed — name the feature/file/area, not just "update code" (e.g. `feat: add dark mode toggle to settings panel`, not `feat: updates`).

Add a body only when the subject alone doesn't explain the "why" — a non-obvious fix, a breaking change, or a change touching multiple areas. Keep it short and factual.

**The message always describes the actual diff, never the source of the task.** If the work came from a plan document with numbered phases (`plan.md`, "Phase 1", "Phase 2", ...), those labels are planning structure, not a description of the change — never write a message like `feat: phase 1`. Look at what the diff actually does and describe that.

## 4. Commit granularity — one commit per logical change

Commit by concern, not by plan milestone. If a single phase of a plan mixes a feature, a refactor, and a test addition, that's three commits (`feat: ...`, `refactor: ...`, `test: ...`), not one. If a phase is already a single clean concern, it naturally collapses to one commit — don't force splitting for its own sake.

## 5. Push cadence — push after every commit

Push immediately after each commit (`git push`), rather than batching commits locally and pushing once at the end. This keeps nothing valuable sitting unpushed if the session is interrupted. No special flags are needed once identity and message are correct — GitHub attributes the commit by the `user.email` on it, so as long as that email matches (or is verified on) the user's GitHub account, the commit shows as authored by them with no co-author.

## 6. If AI attribution already exists in history

If asked to clean up commits that already carry an AI co-author trailer:
- For the latest commit not yet pushed: `git commit --amend` with a corrected message.
- For older or already-pushed commits: this requires rewriting history (`git rebase -i` equivalent, or `git filter-repo`). That's destructive to shared history — explain the tradeoff and get explicit confirmation before doing it, especially if the commits are already pushed (it will require a force-push).
