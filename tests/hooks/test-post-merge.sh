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

if tc_summary "test-post-merge"; then
    exit 0
fi
exit 1
