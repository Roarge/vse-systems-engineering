---
description: Open or append the cross-session continuity journal
argument-hint: "[optional entry text or checkpoint note]"
---

Invoke the `vse-systems-engineering:session-journal` skill to manage the
cross-session continuity journal stored at `.vse-journal.yml`.

Pass the user-supplied arguments through as the entry payload or query for
the skill:

$ARGUMENTS

If the user supplied entry text, append it as a new dated journal entry
covering progress, decisions, and any open issues. If the user supplied no
arguments, summarise the most recent entries, surface pending work, and ask
whether the user wants to add a new checkpoint.
