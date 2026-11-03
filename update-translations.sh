#!/bin/bash
set -euo pipefail
############################################################
# Author    : Erik Dubois
# Website   : https://kiroproject.be
############################################################
#
#   DO NOT JUST RUN THIS. EXAMINE AND JUDGE. RUN AT YOUR OWN RISK.
#
#   Purpose:
#   - Refreshes translations/*.ts from the theme's qsTr() strings
#     (lupdate), then compiles each one into the .qm file SDDM loads
#     from usr/share/sddm/themes/edu-simplicity/translations/.
#
#   Why: SDDM translates its own textConstants; the theme's own
#   strings need .qm files in the TranslationsDirectory that
#   metadata.desktop names. The .ts sources stay outside usr/ so
#   they are not packaged.
#
############################################################

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"

############################################################
# Colors
############################################################
if command -v tput >/dev/null 2>&1 && [[ -t 1 ]]; then
    RED="$(tput setaf 1)"
    GREEN="$(tput setaf 2)"
    YELLOW="$(tput setaf 3)"
    BLUE="$(tput setaf 4)"
    CYAN="$(tput setaf 6)"
    RESET="$(tput sgr0)"
else
    RED="" GREEN="" YELLOW="" BLUE="" CYAN="" RESET=""
fi

############################################################
# Logging
############################################################
log_section() {
    echo
    echo "${GREEN}############################################################${RESET}"
    echo "$1"
    echo "${GREEN}############################################################${RESET}"
    echo
}

log_info() {
    echo
    echo "${BLUE}############################################################${RESET}"
    echo "$1"
    echo "${BLUE}############################################################${RESET}"
    echo
}

log_warn() {
    echo
    echo "${YELLOW}############################################################${RESET}"
    echo "$1"
    echo "${YELLOW}############################################################${RESET}"
    echo
}

log_error() {
    echo
    echo "${RED}############################################################${RESET}"
    echo "$1"
    echo "${RED}############################################################${RESET}"
    echo
}

log_success() {
    echo
    echo "${GREEN}############################################################${RESET}"
    echo "$1"
    echo "${GREEN}############################################################${RESET}"
    echo
}

############################################################
# Error handling
############################################################
on_error() {
    local lineno="$1"
    local cmd="$2"
    echo
    echo "${RED}ERROR on line ${lineno}: ${cmd}${RESET}"
    echo
    sleep 10
}

trap 'on_error "$LINENO" "$BASH_COMMAND"' ERR

############################################################
# Functions
############################################################
THEME_DIR="${SCRIPT_DIR}/usr/share/sddm/themes/edu-simplicity"
TS_DIR="${SCRIPT_DIR}/translations"
QM_DIR="${THEME_DIR}/translations"

update_ts() {
    log_section "Updating .ts files from the QML sources"
    local ts
    for ts in "${TS_DIR}"/*.ts; do
        lupdate -silent -no-obsolete "${THEME_DIR}"/*.qml "${THEME_DIR}"/SimpleControls/*.qml -ts "${ts}"
    done
}

compile_qm() {
    log_section "Compiling .qm files into ${QM_DIR}"
    mkdir -p "${QM_DIR}"
    local ts name
    for ts in "${TS_DIR}"/*.ts; do
        name="$(basename "${ts}" .ts)"
        lrelease -silent "${ts}" -qm "${QM_DIR}/${name}.qm"
    done
    if grep -l 'type="unfinished"' "${TS_DIR}"/*.ts >/dev/null 2>&1; then
        log_warn "Unfinished strings in: $(grep -l 'type="unfinished"' "${TS_DIR}"/*.ts | xargs -n1 basename | tr '\n' ' ')"
    fi
}

main() {
    update_ts
    compile_qm
    log_success "$(basename "$0") done"
}

main "$@"
