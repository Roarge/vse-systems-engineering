#!/usr/bin/env bash
# Behavioural tests for hooks/post-merge.sh: where the hook finds the
# project configuration, and so the engineering root it runs the
# renderers from.
#
# The hook finds .iso-config.yaml through iso_config_path in
# hooks/lib/iso-profile.sh: VSE_ISO_CONFIG when it names a readable
# file, otherwise the greenfield layout at the repository root,
# otherwise the brownfield layout under engineering/. Without the
# library (a partial install) the hook makes the same search itself.
# The directory that holds the file is the engineering root.
#
# Run: bash tests/hooks/test-post-merge.sh
set -euo pipefail

# shellcheck source=/dev/null
. "$(cd "$(dirname "$0")" && pwd)/lib.sh"

trap tc_teardown EXIT

# Install the hook on main with one commit, so that HEAD names main.
setup_main() {
    tc_setup_repo
    tc_install_githook post-merge
    tc_write README.md <<'EOF'
# Scratch project
EOF
    tc_stage README.md
    tc_commit "start the project"
}

# install_renderer <engineering-root>: a renderer under the given root
# that leaves a marker in the directory it runs from, and the
# configuration there that names it.
install_renderer() {
    local eng="$1"
    tc_write "${eng}tools/render/stub.sh" <<'EOF'
#!/usr/bin/env bash
set -euo pipefail
printf 'rendered\n' > rendered.marker
EOF
    chmod +x "${REPO}/${eng}tools/render/stub.sh"
}

renderer_config() {
    cat <<'EOF'
project_profile: full
renderers:
  matrix: tools/render/stub.sh
EOF
}

# assert_rendered <engineering-root> <label>
assert_rendered() {
    local eng="$1" label="$2"
    tc_assert_rc 0 "${label}: the hook exits 0"
    if [ -f "${REPO}/${eng}rendered.marker" ]; then
        tc_pass "${label}: the renderer ran from the engineering root"
    else
        tc_fail "${label}: the renderer ran from the engineering root" \
            "no marker at ${eng}rendered.marker"
    fi
    tc_assert_grep "[post-merge] Derived artefacts" "$OUT" "${label}: the hook reports on the artefacts"
}

case_root_config() {
    setup_main
    install_renderer ""
    renderer_config | tc_write .iso-config.yaml
    tc_env
    tc_run_githook post-merge 0
    assert_rendered "" "root configuration"
}

case_brownfield_config() {
    setup_main
    install_renderer "engineering/"
    renderer_config | tc_write engineering/.iso-config.yaml
    tc_env
    tc_run_githook post-merge 0
    assert_rendered "engineering/" "brownfield configuration"
}

case_vse_iso_config() {
    setup_main
    install_renderer "systems/"
    renderer_config | tc_write systems/vse.yaml
    tc_env "VSE_ISO_CONFIG=${REPO}/systems/vse.yaml"
    tc_run_githook post-merge 0
    assert_rendered "systems/" "VSE_ISO_CONFIG"
}

case_stub_library_root_config() {
    setup_main
    rm -f "${REPO}/.githooks/lib/iso-profile.sh"
    install_renderer ""
    renderer_config | tc_write .iso-config.yaml
    tc_env
    tc_run_githook post-merge 0
    assert_rendered "" "partial install, root configuration"
}

case_stub_library_vse_iso_config() {
    setup_main
    rm -f "${REPO}/.githooks/lib/iso-profile.sh"
    install_renderer "systems/"
    renderer_config | tc_write systems/vse.yaml
    tc_env "VSE_ISO_CONFIG=${REPO}/systems/vse.yaml"
    tc_run_githook post-merge 0
    assert_rendered "systems/" "partial install, VSE_ISO_CONFIG"
}

# --------------------------------------------------------- the drift report

# install_docs_renderer <current|stale>: a renderer at the root that
# writes docs/generated/matrix.md, committed with the content the
# renderer writes when <current> is "current", and with older content
# otherwise.
install_docs_renderer() {
    tc_write tools/render/stub.sh <<'EOF'
#!/usr/bin/env bash
set -euo pipefail
mkdir -p docs/generated
printf 'matrix, regenerated\n' > docs/generated/matrix.md
EOF
    chmod +x "${REPO}/tools/render/stub.sh"
    if [ "$1" = current ]; then
        printf 'matrix, regenerated\n' | tc_write docs/generated/matrix.md
    else
        printf 'matrix, as committed\n' | tc_write docs/generated/matrix.md
    fi
    renderer_config | tc_write .iso-config.yaml
    tc_stage .iso-config.yaml tools/render/stub.sh docs/generated/matrix.md
    tc_commit "add the renderer and its output"
}

case_drift_reported() {
    setup_main
    install_docs_renderer stale
    tc_env
    tc_run_githook post-merge 0
    tc_assert_rc 0 "drift: the hook exits 0"
    tc_assert_line "[post-merge] Derived artefacts regenerated. Commit the updates or run CI." "$OUT" \
        "drift: the regenerated artefacts are reported"
}

case_drift_current() {
    setup_main
    install_docs_renderer current
    tc_env
    tc_run_githook post-merge 0
    tc_assert_rc 0 "no drift: the hook exits 0"
    tc_assert_line "[post-merge] Derived artefacts already current." "$OUT" \
        "no drift: the artefacts are reported current"
}

# git diff exits 1 for a difference and 128 when it cannot compare, here
# because the index is damaged. Only 1 is drift.
case_drift_git_error() {
    setup_main
    install_docs_renderer current
    printf 'not an index\n' > "${REPO}/.git/index"
    tc_env
    tc_run_githook post-merge 0
    tc_assert_rc 0 "drift check fails: the hook exits 0"
    tc_assert_not_grep "regenerated. Commit the updates" "$OUT" \
        "drift check fails: no drift is reported"
    tc_assert_not_grep "already current" "$OUT" \
        "drift check fails: the artefacts are not called current"
    tc_assert_grep "[post-merge] git could not compare the derived artefacts" "$ERR" \
        "drift check fails: the hook says the comparison failed"
}

# An engineering root outside the repository has no derived artefacts
# git can compare, so the renderers run and no drift is reported.
case_eng_root_outside() {
    local outside
    setup_main
    outside="$(tc_mktemp_d)"
    mkdir -p "${outside}/tools/render"
    printf '#!/usr/bin/env bash\nprintf "rendered\\n" > rendered.marker\n' \
        > "${outside}/tools/render/stub.sh"
    chmod +x "${outside}/tools/render/stub.sh"
    renderer_config > "${outside}/vse.yaml"
    tc_env "VSE_ISO_CONFIG=${outside}/vse.yaml"
    tc_run_githook post-merge 0
    tc_assert_rc 0 "engineering root outside: the hook exits 0"
    if [ -f "${outside}/rendered.marker" ]; then
        tc_pass "engineering root outside: the renderer ran there"
    else
        tc_fail "engineering root outside: the renderer ran there" "no marker in ${outside}"
    fi
    tc_assert_not_grep "Derived artefacts" "$OUT" "engineering root outside: no drift report"
    tc_assert_empty "$ERR" "engineering root outside: git reports no error"
}

case_no_config_silent() {
    setup_main
    tc_env
    tc_run_githook post-merge 0
    tc_assert_rc 0 "no configuration: the hook exits 0"
    tc_assert_empty "$OUT" "no configuration: the hook prints nothing"
}

case_root_config
case_brownfield_config
case_vse_iso_config
case_stub_library_root_config
case_stub_library_vse_iso_config
case_no_config_silent
case_drift_reported
case_drift_current
case_drift_git_error
case_eng_root_outside

if tc_summary "test-post-merge"; then
    exit 0
fi
exit 1
