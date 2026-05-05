#!/usr/bin/env bash
# Project-side git pre-push hook.
#
# Per methodology/iso-29110-hooks-guide.md §4.4. Final compliance gate
# before changes leave the local repository. More expensive checks
# than pre-commit.
#
# Four concerns:
#   1. Story state on main: reject pushes that land inProgress stories.
#   2. V&V coverage: reject pushes where done stories lack verification.
#   3. Traceability matrix freshness: reject if regen would change it.
#   4. Baseline integrity on tags: when pushing a release-* tag.
#
# Install as <project>/.githooks/pre-push.
set -euo pipefail

while read -r local_ref local_sha remote_ref remote_sha; do
    case "$remote_ref" in
        refs/heads/main|refs/heads/release/*)
            # Story state check: stub.
            # Real implementation greps for `status = inProgress` in stories
            # whose files would land in the push.
            : # passthrough until tools/lint/check-no-inprogress.py lands

            # V&V coverage check: stub.
            : # passthrough until tools/lint/vv-coverage.py lands

            # Traceability matrix freshness: stub.
            : # passthrough until tools/render/traceability-matrix.py lands
            ;;
        refs/tags/release-*)
            # Baseline integrity: stub.
            : # passthrough until tools/lint/baseline-integrity.py lands
            ;;
    esac
done

# In v2.0-rc, the pre-push checks above are stubs that pass through.
# The full implementations land in tools/lint/ and tools/render/ as
# the project's CM Strategy matures. The corresponding CI workflow at
# .github/workflows/compliance.yml is the unbypassable gate.

exit 0
