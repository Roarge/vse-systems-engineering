# Git Workflow

**Never commit directly to `main`.** `main` is the default branch
installers fetch via `/plugin marketplace add`, so anything that lands
there reaches end users on their next reinstall. All changes, however
small, go through a feature branch and a pull request.

**Branch naming** uses conventional-commit prefixes: `feat/<slug>`,
`fix/<slug>`, `docs/<slug>`, `chore/<slug>`, `refactor/<slug>`. When a
branch closes a GitHub issue, create it with
`gh issue develop <n> --name <branch> --base main` so the issue links it.

**Workflow for any edit:**

1. Run `git branch --show-current` before touching any file. On `main`,
   create and check out a feature branch immediately.
2. Commit in small, scoped units with conventional-commit subjects and a
   scope where possible, for example
   `feat(lifecycle-orchestrator): add change request handling`. The body
   explains why the change is needed, not just what it does.
3. Open the pull request **as a draft** (`gh pr create --draft`).
   Copilot starts its one and only review the moment a PR leaves draft
   mode and never reviews later changes. Keep the PR in draft through
   Claude's own review and any fixes that follow, then mark it ready
   (`gh pr ready`) only when the PR is believed final.
4. Do not merge the PR. The user reviews and merges.
5. The version bump and `CHANGELOG.md` update are the final commit on
   the feature branch, not a separate PR.

**Attribution.** Commits are always authored as the repo git user and
carry NO AI attribution: no `Co-Authored-By: Claude ...` trailers and no
"Generated with Claude Code" footers, in commit messages or pull request
bodies.

**If a commit lands on `main` by accident:** stop, do not rewrite
history silently. Flag it to the user and ask for authorisation before
any destructive operation on `main` (reset, rebase, force push).

**Known repo quirk:** `gh pr edit` fails on this repo with a
projects-classic GraphQL error. Use
`gh api -X PATCH repos/<owner>/<repo>/pulls/<n>` instead.
