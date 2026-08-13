# Contributor Role and Distribution Rule

This repository IS the `vse-systems-engineering` Claude Code plugin.
Treat requests here as work on the plugin itself (skills, hooks, wiki,
manifests, templates, methodology, the demo, developer documentation),
not as engineering a system with it. End-user behaviour is exercised
inside `demo/smart-sensor/`, which carries its own `CLAUDE.md`. If asked
for VSE engineering work in the repo root, flag the ambiguity once, then
proceed.

**What ships.** Installing the plugin clones the entire committed git
tree into the installer's `${CLAUDE_PLUGIN_ROOT}`. Every tracked file
reaches end users. The only content that does not ship is gitignored
content, currently `sources/`, `dev_docs/`, `.obsidian/`, `.envrc`,
`.claude/` (except the committed `rules/`), and `CLAUDE.local.md`.

**What activates.** The harness auto-loads only the mount points in
`.claude-plugin/plugin.json`: skills from `skills/`, slash commands from
`commands/`, lifecycle hooks via `hooks.json`. Subagents load by
convention from `agents/` (see the skills-and-commands rules for why the
manifest carries no agents field). Everything else that ships
(`templates/`, `wiki/`, `methodology/`, unregistered `hooks/` scripts)
is passive content addressed via `${CLAUDE_PLUGIN_ROOT}/...` from skill
bodies. A `CLAUDE.md` or `.claude/rules/` inside the plugin tree is not
loaded in the installer's workspace, because instructions load from the
user's working directory only.

**Implications.** A behaviour that must activate for end users lives in
a skill or a registered hook. Content that only needs to be readable at
a stable path may live anywhere in the committed tree. Anything that
must reach end users must be committed, and gitignored files genuinely
do not ship.
