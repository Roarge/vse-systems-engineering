---
paths:
  - "skills/**"
  - "commands/**"
  - "agents/**"
---

# Skills, Commands, and Subagents

**Skills.** Each skill lives in `skills/<name>/SKILL.md` with per-skill
assets beside it. Frontmatter requires `name` and `description`, and
the description is the activation hint, so it must be precise,
trigger-rich, and short ("use when..." language). Prefer extending an
existing skill over adding a new one: the plugin ships 28 skills as of
3.0.0 and discoverability degrades as the count grows. Splitting is
justified past roughly 500 lines or two clearly distinct triggers.
Reference material lives in the wiki, reached through the generated
routing marker block in the skill body. Never hand-edit inside the
markers and never front-load page content into a skill body. When
resolving user-facing questions inside skill content, the plugin's
`methodology/` specification overrides every external source.

**Commands.** Slash commands live in `commands/<name>.md`, one file per
command. Each is a thin wrapper that delegates to a named skill and
forwards arguments, never reimplements skill logic. Keep the first
lines short and trigger-rich for the slash menu. Test by installing the
working branch as a local plugin and running the command inside
`demo/smart-sensor/`.

**Subagents.** Subagents live in `agents/<name>.md` with a restricted
tool surface declared in frontmatter, default `Read`, `Glob`, `Grep`.
Never grant `Write`, `Edit`, or any file-modifying tool. Subagents
return suggestion-shaped markdown to a dispatching skill, which
surfaces the proposal to the engineer. Each subagent has exactly one
orchestrating skill, documented in its description. Prefer
parallelisable, context-heavy work for subagents, and test a subagent
by triggering its parent skill inside `demo/smart-sensor/` with the
branch installed as a local plugin.

**The manifest carries no agents field, deliberately.** Tested evidence
(PR #63, at pinned CLI 2.1.224): the validator rejects every
directory-shaped form of an `agents` field and accepts only an array of
individual file paths. A per-file array would silently drop any future
agent file not enumerated. The repo therefore relies on convention
discovery from `agents/`. Do not re-add the field in any form.
