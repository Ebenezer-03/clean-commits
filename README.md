# clean-commits

Every commit authored solely by *you* — never an AI co-author — with production-grade [Conventional Commits](https://www.conventionalcommits.org/) messages. Works as a native Claude Code skill, or as a plain `AGENTS.md` for any other coding agent (Codex, Cursor, Aider, ...).

## What it does

When an agent is about to commit on your behalf, this skill:

1. **Asks for exactly two things, once per repo**: your email address and your GitHub username. It verifies the username against the GitHub API and persists the identity to that repo's local git config — never global, so other repos are untouched.
2. **Strips all AI attribution** — no `Co-Authored-By: Claude`, no session links, no "Generated with ..." lines, regardless of what the agent's default template wants to add.
3. **Enforces Conventional Commits** on every message: `feat`, `fix`, `update`, `refactor`, `docs`, `style`, `test`, `perf`, `build`, `ci`, `chore` — imperative mood, specific, no filler.
4. **Commits by logical change, not by plan milestone.** If you hand the agent a `plan.md` with numbered phases and it executes the whole thing, you get one commit per concern (a feature, a refactor, a fix), not one commit per phase — and never a message like `feat: phase 1`.
5. **Pushes after every commit**, so nothing sits unpushed if the session gets interrupted.

## Install

### Claude Code

Add this repo as a plugin marketplace, then install the plugin:

```bash
/plugin marketplace add Ebenezer-03/clean-commits
/plugin install clean-commits
```

### Any other agent (Codex, Cursor, Aider, ...)

Copy [`AGENTS.md`](./AGENTS.md) from this repo into the root of your own project (or merge its contents into an existing `AGENTS.md`). Any tool that reads `AGENTS.md` will pick up the same rules.

## Why

Commit history is a product surface — it's what shows up in `git blame`, PR reviews, and changelogs. Mixed authorship trailers and inconsistent messages make that history harder to trust and search. This skill keeps authorship honest and messages standardized, automatically, without you having to remember to ask for it every time.

## License

MIT — see [LICENSE](./LICENSE).
