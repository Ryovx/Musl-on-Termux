#!/data/data/com.termux/files/usr/bin/bash
# ═══════════════════════════════════════════════════════════════════════════
#                                                                           #
#     ███╗   ███╗ ██████╗ ████████╗                                         #
#     ████╗ ████║██╔═══██╗╚══██╔══╝                                         #
#     ██╔████╔██║██║   ██║   ██║                                            #
#     ██║╚██╔╝██║██║   ██║   ██║                                            #
#     ██║ ╚═╝ ██║╚██████╔╝   ██║                                            #
#     ╚═╝     ╚═╝ ╚═════╝    ╚═╝                                            #
#                                                                           #
#     ███╗   ███╗██╗   ██╗███████╗██╗                                       #
#     ████╗ ████║██║   ██║██╔════╝██║                                       #
#     ██╔████╔██║██║   ██║███████╗██║                                       #
#     ██║╚██╔╝██║██║   ██║╚════██║██║                                       #
#     ██║ ╚═╝ ██║╚██████╔╝███████║███████╗                                  #
#     ╚═╝     ╚═╝ ╚═════╝ ╚══════╝╚══════╝                                  #
#                                                                           #
#                     T E R M U X   R U N N E R                             #
#                                                                           #
# ═══════════════════════════════════════════════════════════════════════════
#
#   MoT Installer Script
#   ─────────────────────────────────────────────────────────────────────
#   Developed & Maintained by / Ryovx
#   Version:      1.3.2
#   License:      GNU General Public License v3.0 or later
#   Runtime:      https://github.com/Ryovx/Musl-on-Termux
#
# ═══════════════════════════════════════════════════════════════════════════
#
#   ╔═══════════════════════════════════════════════════════════════════╗
#   ║                                                                   ║
#   ║                    ▓▓▓  F R E E   S O F T W A R E  ▓▓▓            ║
#   ║                                                                   ║
#   ║   This script is provided FREE OF CHARGE to the Termux            ║
#   ║   community.                                                      ║
#   ║                                                                   ║
#   ║   ♥  The author kindly REQUESTS that you do NOT sell, resell,     ║
#   ║      or bundle this script with any paid product.                 ║
#   ║                                                                   ║
#   ║      This is an ETHICAL REQUEST, not a legal restriction.         ║
#   ║      Under GPLv3 you retain the full right to redistribute        ║
#   ║      this software, including commercially, provided you          ║
#   ║      comply with the license terms.                               ║
#   ║                                                                   ║
#   ║   ✔  We are proud members of the Open Invention Network (OIN)     ║
#   ║                                                                   ║
#   ║   This software is provided "AS IS", without warranty of any      ║
#   ║   kind.                                                           ║
#   ║                                                                   ║
#   ╚═══════════════════════════════════════════════════════════════════╝
#
# ═══════════════════════════════════════════════════════════════════════════
#
#   ONE COMMAND INSTALL
#   ─────────────────────────────────────────────────────────────────────
#       curl -fsSL https://raw.githubusercontent.com/Ryovx/Musl-on-Termux/main/install.sh | bash
#
#   UNINSTALL
#   ─────────────────────────────────────────────────────────────────────
#       mot --uninstall
#   or:
#       bash install.sh --uninstall
#
#   NOTE: `mot --uninstall` removes the mot binary itself. To reinstall:
#       curl -fsSL https://raw.githubusercontent.com/Ryovx/Musl-on-Termux/main/install.sh | bash
#
# ═══════════════════════════════════════════════════════════════════════════
#
#   INSTALLED ARTIFACTS
#   ─────────────────────────────────────────────────────────────────────
#     $PREFIX/bin/mot                   The runner
#     $PREFIX/lib/musl/                 musl loader + libs
#     $PREFIX/lib/musl/mot.template     Source of truth for `mot --fix`
#     $PREFIX/lib/musl/.install-manifest  Version tracking
#
# ═══════════════════════════════════════════════════════════════════════════

set -Eeuo pipefail

readonly SCRIPT_NAME="MoT Installer Script"
readonly SCRIPT_VERSION="1.3.2"
readonly SCRIPT_AUTHOR="Ryovx"

readonly PREFIX="${PREFIX:-/data/data/com.termux/files/usr}"
readonly HOME_DIR="${HOME:-/data/data/com.termux/files/home}"

readonly MUSL_DIR="$PREFIX/lib/musl"
readonly MUSL_LOADER="$MUSL_DIR/ld-musl-aarch64.so.1"
readonly MOT_BIN="$PREFIX/bin/mot"
readonly MOT_TMPL="$MUSL_DIR/mot.template"
readonly MANIFEST="$MUSL_DIR/.install-manifest"

readonly MUSL_RUNTIME_VERSION="1.2.6"
readonly MOT_VERSION="1.3.2"

readonly MUSL_ZIP_URL="https://github.com/Ryovx/Musl-on-Termux/releases/download/v1.2.6-termux/musl-on-termux-aarch64.zip"
readonly MUSL_ZIP_SHA256="e4f456187a54f6fbbcda31026354728262b5acfce11642eaca2df88722c9870b"
readonly MUSL_ZIP_NAME="musl-on-termux-aarch64.zip"

readonly INSTALLER_URL="https://raw.githubusercontent.com/Ryovx/Musl-on-Termux/main/install.sh"
readonly MIN_FREE_MB=200

if [[ -t 2 ]] && [[ -z "${NO_COLOR:-}" ]]; then
  readonly C_RST=$'\033[0m' C_RED=$'\033[1;31m' C_GRN=$'\033[1;32m'
  readonly C_YEL=$'\033[1;33m' C_CYN=$'\033[1;36m' C_BLD=$'\033[1m' C_MAG=$'\033[1;35m'
else
  readonly C_RST="" C_RED="" C_GRN="" C_YEL="" C_CYN="" C_BLD="" C_MAG=""
fi

log_info() { printf '%s %s\n' "${C_CYN}->${C_RST}" "$*" >&2; }
log_ok()   { printf '%s %s\n' "${C_GRN}+${C_RST}"  "$*" >&2; }
log_warn() { printf '%s %s\n' "${C_YEL}!${C_RST}"  "$*" >&2; }
log_fail() { printf '%s %s\n' "${C_RED}x${C_RST}"  "$*" >&2; }
die()      { log_fail "$*"; exit 1; }

WORK_DIR=""
cleanup_work() {
  if [[ -n "${WORK_DIR:-}" && -d "$WORK_DIR" ]]; then
    rm -rf -- "$WORK_DIR" 2>/dev/null || true
  fi
}
trap cleanup_work EXIT

assert_termux_prefix() {
  case "$PREFIX" in
    */com.termux/files/usr) ;;
    *)
      die "Refusing: PREFIX=$PREFIX does not look like a Termux prefix.
This safeguard prevents accidental damage on non-Termux systems."
      ;;
  esac
}

get_manifest_value() {
  local key="$1" val=""
  [[ -f "$MANIFEST" ]] || return 1
  val="$(grep -E "^${key}=" "$MANIFEST" 2>/dev/null | head -n1 | cut -d= -f2-)" || true
  [[ -n "$val" ]] || return 1
  printf '%s\n' "$val"
}

write_manifest() {
  cat > "$MANIFEST" <<EOF
mot=$MOT_VERSION
musl=$MUSL_RUNTIME_VERSION
EOF
  chmod 0644 "$MANIFEST"
}

needs_musl_install() {
  [[ -x "$MUSL_LOADER" ]] || return 0
  local v
  v="$(get_manifest_value musl 2>/dev/null || true)"
  [[ "$v" == "$MUSL_RUNTIME_VERSION" ]] && return 1
  return 0
}

needs_mot_install() {
  [[ -x "$MOT_BIN" ]] || return 0
  local v
  v="$(get_manifest_value mot 2>/dev/null || true)"
  [[ "$v" == "$MOT_VERSION" ]] && return 1
  return 0
}

cleanup_stale() {
  log_info "Cleaning up stale artifacts..."
  rm -rf -- "$MUSL_DIR".new.* "$MUSL_DIR".old.* 2>/dev/null || true
  rm -f  -- "$MUSL_DIR"/*.zip "$MUSL_DIR"/*.tmp.* 2>/dev/null || true
  rm -f  -- "$MOT_BIN".tmp.* 2>/dev/null || true
  log_ok "Cleanup complete"
}

check_environment() {
  log_info "Checking environment..."
  [[ -d "$PREFIX" ]]   || die "PREFIX does not exist: $PREFIX"
  [[ -w "$PREFIX" ]]   || die "PREFIX is not writable: $PREFIX"
  [[ "$(uname -m)" == "aarch64" ]] \
    || die "Unsupported architecture: $(uname -m) (only aarch64 is supported)"
  log_ok "Environment OK"
}

check_disk_space() {
  local avail_mb
  avail_mb="$(df -Pk "$HOME_DIR" 2>/dev/null | awk 'NR==2 {print int($4/1024)}')"
  [[ -n "$avail_mb" ]] || avail_mb=0
  [[ "$avail_mb" -ge "$MIN_FREE_MB" ]] \
    || die "Insufficient free space: ${avail_mb}MB available, ${MIN_FREE_MB}MB required"
  log_ok "Disk space OK (${avail_mb}MB free)"
}

ensure_packages() {
  log_info "Ensuring required packages..."
  local missing=()
  command -v curl    >/dev/null 2>&1 || missing+=(curl)
  command -v unzip   >/dev/null 2>&1 || missing+=(unzip)
  command -v readelf >/dev/null 2>&1 || missing+=(binutils)
  if [[ ${#missing[@]} -gt 0 ]]; then
    log_info "Installing: ${missing[*]}"
    pkg install -y "${missing[@]}" \
      || die "Failed to install: ${missing[*]}"
  fi
  log_ok "Required packages present"
}

install_musl_runtime() {
  local force="${1:-0}"

  if [[ "$force" != "1" ]] && ! needs_musl_install; then
    log_ok "musl runtime $MUSL_RUNTIME_VERSION already present (skipping)"
    return 0
  fi

  log_info "Downloading musl runtime $MUSL_RUNTIME_VERSION..."
  log_info "  from: $MUSL_ZIP_URL"
  WORK_DIR="$(mktemp -d)"
  local zip_path="$WORK_DIR/$MUSL_ZIP_NAME"
  local new_dir="$MUSL_DIR.new.$$"
  local old_dir="$MUSL_DIR.old.$$"

  rm -rf -- "$new_dir" "$old_dir" 2>/dev/null || true

  curl -fsSL --connect-timeout 30 --max-time 300 \
    --retry 3 --retry-delay 2 \
    -o "$zip_path" "$MUSL_ZIP_URL" \
    || die "Failed to download musl runtime"

  local actual_sha
  actual_sha="$(sha256sum "$zip_path" | awk '{print $1}')"
  [[ "$actual_sha" == "$MUSL_ZIP_SHA256" ]] \
    || die "SHA256 mismatch!
  expected: $MUSL_ZIP_SHA256
  actual:   $actual_sha"
  log_ok "SHA256 verified"

  mkdir -p "$new_dir"
  unzip -o -q "$zip_path" -d "$new_dir" \
    || { rm -rf -- "$new_dir"; die "Failed to extract musl runtime"; }

  [[ -f "$new_dir/ld-musl-aarch64.so.1" ]] \
    || { rm -rf -- "$new_dir"; die "musl loader not found in archive"; }
  chmod 0755 "$new_dir/ld-musl-aarch64.so.1"

  [[ ! -e "$new_dir/libc.so" ]] \
    && ln -sf -- "ld-musl-aarch64.so.1" "$new_dir/libc.so" || true

  if [[ -d "$MUSL_DIR" ]]; then
    mv -- "$MUSL_DIR" "$old_dir" \
      || { rm -rf -- "$new_dir"; die "Failed to move old runtime aside"; }
  fi
  if mv -- "$new_dir" "$MUSL_DIR"; then
    rm -rf -- "$old_dir" 2>/dev/null || true
  else
    [[ -d "$old_dir" ]] && mv -- "$old_dir" "$MUSL_DIR" 2>/dev/null || true
    rm -rf -- "$new_dir" 2>/dev/null || true
    die "Failed to install new runtime — old restored"
  fi

  log_ok "musl runtime installed ($MUSL_DIR)"
}

install_mot() {
  local force="${1:-0}"

  if [[ "$force" != "1" ]] && ! needs_mot_install; then
    log_ok "mot $MOT_VERSION already installed (skipping)"
    return 0
  fi

  log_info "Installing mot runner $MOT_VERSION..."
  mkdir -p "$(dirname "$MOT_BIN")" "$MUSL_DIR"

  local tmpl_tmp="$MOT_TMPL.tmp.$$"

  cat > "$tmpl_tmp" <<'__MOT_SCRIPT_END__'
#!/data/data/com.termux/files/usr/bin/bash
# ═══════════════════════════════════════════════════════════════════════════
# mot 1.3.2 — run anything using musl on Termux
# Copyright © 2026 Ryovx. Licensed under GNU GPL v3.0 or later.
# DO NOT EDIT. Restore with: mot --fix
# ═══════════════════════════════════════════════════════════════════════════
set -euo pipefail

readonly MOT_VERSION="1.3.2"
readonly PREFIX="${PREFIX:-/data/data/com.termux/files/usr}"
readonly MUSL="$PREFIX/lib/musl"
readonly MUSL_LOADER="$MUSL/ld-musl-aarch64.so.1"
readonly MOT_BIN="$PREFIX/bin/mot"
readonly MOT_TMPL="$MUSL/mot.template"
readonly INSTALLER_URL="https://raw.githubusercontent.com/Ryovx/Musl-on-Termux/main/install.sh"

die() { printf 'mot: %s\n' "$*" >&2; exit 1; }

usage() {
  cat <<'__MOT_USAGE_END__'
mot — run anything using musl on Termux

USAGE
  mot COMMAND [ARGS...]     Run COMMAND with the musl runtime
  mot -- COMMAND [ARGS...]  Same as above (explicit separator)
  mot -h, --help            Show this help
  mot -v, --version         Show version
  mot -i, --install         Install/refresh musl runtime + mot
  mot -u, --update          Force reinstall (re-download runtime)
  mot -f, --fix             Restore mot from its template
  mot -x, --uninstall       Remove mot and the musl runtime

EXAMPLES
  mot claude                Run Claude Code under musl
  mot echo "hi"             Run the echo builtin
  mot zip                   Run zip with musl libraries
  mot ls -la                Run ls with musl libraries
  mot bash                  Start a bash shell with musl env

NOTE
  `mot --uninstall` removes the mot binary itself. To reinstall:
      curl -fsSL https://raw.githubusercontent.com/Ryovx/Musl-on-Termux/main/install.sh | bash

EXIT STATUS
  0    Success
  1    Usage error or runtime missing
  126  Command found but not executable
  127  Command not found
__MOT_USAGE_END__
}

ensure_runtime() {
  [[ -x "$MUSL_LOADER" ]] || die "musl runtime not found at $MUSL — run: mot --install"
}

elf_interp() {
  local f="$1" out=""
  if command -v readelf >/dev/null 2>&1; then
    out="$(readelf -l "$f" 2>/dev/null \
      | sed -n 's/.*Requesting program interpreter: \(.*\)/\1/p' \
      | head -n1 || true)"
  fi
  if [[ -z "$out" ]] && command -v file >/dev/null 2>&1; then
    out="$(file "$f" 2>/dev/null \
      | sed -n 's/.*interpreter \(.*\),.*/\1/p' \
      | head -n1 || true)"
  fi
  printf '%s\n' "${out:-}"
}

run_command() {
  [[ $# -gt 0 ]] || die "no command specified (try: mot --help)"

  local cmd="$1"
  shift

  export MUSL_ON_TERMUX=1

  # Shell builtins, functions, keywords, aliases: run in current shell.
  local ctype
  ctype="$(type -t "$cmd" 2>/dev/null || true)"
  case "$ctype" in
    builtin|function|keyword|alias)
      command "$cmd" "$@"
      return $?
      ;;
  esac

  # External file: resolve to a path.
  local target=""
  if [[ "$cmd" == */* ]]; then
    target="$cmd"
  else
    target="$(command -v "$cmd" 2>/dev/null || true)"
  fi

  [[ -n "$target" ]] || { printf 'mot: command not found: %s\n' "$cmd" >&2; exit 127; }
  [[ -f "$target" ]] || die "not a file: $target"
  [[ -x "$target" ]] || { printf 'mot: not executable: %s\n' "$target" >&2; exit 126; }

  local interp
  interp="$(elf_interp "$target")"

  if [[ "$interp" == *ld-musl-* ]]; then
    env -u LD_PRELOAD MUSL_ON_TERMUX=1 \
      "$MUSL_LOADER" --library-path "$MUSL" \
      "$target" "$@"
  else
    "$target" "$@"
  fi
}

cmd_install() {
  [[ $# -eq 0 ]] || die "mot --install takes no arguments"
  command -v curl >/dev/null 2>&1 || die "curl not found — run: pkg install curl"
  printf 'mot: running installer from %s\n' "$INSTALLER_URL" >&2
  local tmp rc=0
  tmp="$(mktemp)"
  if ! curl -fsSL --connect-timeout 30 --max-time 300 "$INSTALLER_URL" -o "$tmp"; then
    rm -f -- "$tmp"
    die "failed to download installer"
  fi
  bash "$tmp" || rc=$?
  rm -f -- "$tmp"
  exit "$rc"
}

cmd_update() {
  [[ $# -eq 0 ]] || die "mot --update takes no arguments"
  command -v curl >/dev/null 2>&1 || die "curl not found — run: pkg install curl"
  printf 'mot: running installer (--force) from %s\n' "$INSTALLER_URL" >&2
  local tmp rc=0
  tmp="$(mktemp)"
  if ! curl -fsSL --connect-timeout 30 --max-time 300 "$INSTALLER_URL" -o "$tmp"; then
    rm -f -- "$tmp"
    die "failed to download installer"
  fi
  bash "$tmp" --force || rc=$?
  rm -f -- "$tmp"
  exit "$rc"
}

cmd_fix() {
  [[ -f "$MOT_TMPL" ]] || die "template missing at $MOT_TMPL — run: mot --install"
  local tmp="$MOT_BIN.tmp.$$"
  cp -- "$MOT_TMPL" "$tmp"
  chmod 0755 "$tmp"
  mv -- "$tmp" "$MOT_BIN"
  "$MOT_BIN" --version >/dev/null 2>&1 \
    || die "restore failed — template corrupt? run: mot --install"
  printf 'mot: restored from template\n'
}

cmd_uninstall() {
  case "$PREFIX" in
    */com.termux/files/usr) ;;
    *) die "Refusing: PREFIX=$PREFIX does not look like a Termux prefix" ;;
  esac
  printf 'mot: removing mot and musl runtime...\n'
  rm -f  -- "$MOT_BIN" 2>/dev/null || true
  rm -rf -- "$MUSL"    2>/dev/null || true
  printf 'mot: uninstalled\n'
  printf 'mot: to reinstall:\n'
  printf '  curl -fsSL %s | bash\n' "$INSTALLER_URL"
}

main() {
  [[ $# -eq 0 ]] && { usage; exit 1; }

  case "$1" in
    -h|--help)      usage; exit 0 ;;
    -v|--version)   printf 'mot %s (Musl on Termux)\n' "$MOT_VERSION"; exit 0 ;;
    -i|--install)   shift; cmd_install "$@" ;;
    -u|--update)    shift; cmd_update "$@" ;;
    -f|--fix)       shift; cmd_fix ;;
    -x|--uninstall) shift; cmd_uninstall ;;
    --)             shift; ensure_runtime; run_command "$@" ;;
    -*)             printf 'mot: unknown option: %s (try --help)\n' "$1" >&2; exit 1 ;;
    *)              ensure_runtime; run_command "$@" ;;
  esac
}

main "$@"
__MOT_SCRIPT_END__

  chmod 0755 "$tmpl_tmp"
  mv -- "$tmpl_tmp" "$MOT_TMPL"

  local bin_tmp="$MOT_BIN.tmp.$$"
  cp -- "$MOT_TMPL" "$bin_tmp"
  chmod 0755 "$bin_tmp"
  mv -- "$bin_tmp" "$MOT_BIN"

  log_ok "mot installed ($MOT_BIN)"
}

verify_installation() {
  log_info "Verifying installation..."

  [[ -x "$MUSL_LOADER" ]] || die "musl loader not executable: $MUSL_LOADER"
  [[ -x "$MOT_BIN" ]]     || die "mot not executable: $MOT_BIN"
  log_ok "Files present and executable"

  local out rc

  # 1. mot --version
  rc=0; out="$("$MOT_BIN" --version 2>&1)" || rc=$?
  [[ $rc -eq 0 ]] || die "mot --version failed (rc=$rc): $out"
  [[ "$out" == mot* ]] || die "mot --version unexpected: $out"
  log_ok "mot --version: $out"

  # 2. mot --help
  rc=0; "$MOT_BIN" --help >/dev/null 2>&1 || rc=$?
  [[ $rc -eq 0 ]] || die "mot --help failed (rc=$rc)"
  log_ok "mot --help OK"

  # 3. mot echo (builtin path)
  rc=0; out="$("$MOT_BIN" echo "MOT_BUILTIN_OK" 2>&1)" || rc=$?
  [[ $rc -eq 0 ]] || die "mot echo failed (rc=$rc): $out"
  [[ "$out" == "MOT_BUILTIN_OK" ]] || die "mot echo wrong output: $out"
  log_ok "mot builtin path OK"

  # 4. mot uname (external ELF path)
  rc=0; out="$("$MOT_BIN" uname -s 2>&1)" || rc=$?
  [[ $rc -eq 0 ]] || die "mot uname failed (rc=$rc): $out"
  [[ "$out" == "Linux" ]] || die "mot uname wrong output: $out"
  log_ok "mot external ELF path OK"

  # 5. mot claude (optional)
  if command -v claude >/dev/null 2>&1; then
    rc=0; out="$("$MOT_BIN" claude --version 2>&1)" || rc=$?
    if [[ $rc -eq 0 && "$out" == *"Claude Code"* ]]; then
      log_ok "mot claude OK ($out)"
    else
      log_warn "mot claude returned (rc=$rc): $out"
    fi
  fi
}

print_summary() {
  cat <<SUMMARY

${C_MAG}${C_BLD}╔═══════════════════════════════════════════════════════════════════╗${C_RST}
${C_MAG}${C_BLD}║                                                                   ║${C_RST}
${C_MAG}${C_BLD}║           +  MUSL ON TERMUX INSTALLED SUCCESSFULLY                ║${C_RST}
${C_MAG}${C_BLD}║                                                                   ║${C_RST}
${C_MAG}${C_BLD}╚═══════════════════════════════════════════════════════════════════╝${C_RST}

  ${C_BLD}Quick Start${C_RST}
    mot claude                      Run Claude Code under musl
    mot echo "YES from MOT"         Run the echo builtin
    mot ./rust-tool --version       Run a musl ELF
    mot zip                         Run a non-musl ELF with musl libs
    mot --help                      Full help

  ${C_BLD}Management${C_RST}
    mot -i, --install               Install/refresh the musl runtime
    mot -u, --update                Force reinstall (re-download)
    mot -f, --fix                   Restore mot from template
    mot -x, --uninstall             Remove mot and the musl runtime

  ${C_BLD}Versions${C_RST}
    installer  ${C_CYN}${SCRIPT_VERSION}${C_RST}    mot  ${C_CYN}${MOT_VERSION}${C_RST}    musl  ${C_CYN}${MUSL_RUNTIME_VERSION}${C_RST}

  ${C_BLD}Installed artifacts${C_RST}
    Runner     ${C_CYN}${MOT_BIN}${C_RST}
    Template   ${C_CYN}${MOT_TMPL}${C_RST}
    musl libs  ${C_CYN}${MUSL_DIR}${C_RST}
    Loader     ${C_CYN}${MUSL_LOADER}${C_RST}
    Manifest   ${C_CYN}${MANIFEST}${C_RST}

  ${C_BLD}Reinstall after uninstall${C_RST}
    curl -fsSL ${INSTALLER_URL} | bash

${C_YEL}${C_BLD}───────────────────────────────────────────────────────────────────${C_RST}
${C_YEL}${C_BLD}  FREE SOFTWARE - provided free of charge to the Termux community.${C_RST}
${C_YEL}${C_BLD}  The author kindly requests that you do NOT sell, resell, or     ${C_RST}
${C_YEL}${C_BLD}  bundle this software with paid products.                     ${C_RST}
${C_YEL}${C_BLD}  Licensed under GNU GPL v3.0 or later - see LICENSE for terms.${C_RST}
${C_YEL}${C_BLD}───────────────────────────────────────────────────────────────────${C_RST}

SUMMARY
}

do_uninstall() {
  assert_termux_prefix
  log_info "Uninstalling MoT..."
  rm -f  -- "$MOT_BIN"  2>/dev/null || true
  rm -rf -- "$MUSL_DIR" 2>/dev/null || true
  log_ok "Uninstall complete"
}

print_usage() {
  cat <<'USAGE_EOF'
$SCRIPT_NAME v$SCRIPT_VERSION
Developed & Maintained by / $SCRIPT_AUTHOR

USAGE
  bash install.sh                Install mot + musl runtime (default)
  bash install.sh -i|--install   Same as above (explicit)
  bash install.sh -u|--update    Force reinstall (same as --force)
  bash install.sh -f|--force     Force reinstall
  bash install.sh --uninstall    Remove everything
  bash install.sh -v|--version   Print version
  bash install.sh -h|--help      Show this help

AFTER INSTALL
  mot claude                     Run Claude Code under musl
  mot echo "YES from MOT"        Run the echo builtin
  mot --help                     Full mot help
  mot --uninstall                Remove mot + musl runtime

NOTE
  `mot --uninstall` removes the mot binary itself. To reinstall after
  uninstall, run:
      curl -fsSL https://raw.githubusercontent.com/Ryovx/Musl-on-Termux/main/install.sh | bash
USAGE_EOF
}

main() {
  local FORCE=0
  while [[ $# -gt 0 ]]; do
    case "$1" in
      -h|--help)     print_usage; exit 0 ;;
      -v|--version)  printf '%s v%s\n' "$SCRIPT_NAME" "$SCRIPT_VERSION"; exit 0 ;;
      --uninstall)   do_uninstall; exit 0 ;;
      -i|--install)  shift ;;
      -f|--force|-u|--update) FORCE=1; shift ;;
      *)             die "Unknown argument: $1 (try --help)" ;;
    esac
  done

  assert_termux_prefix

  printf '\n%s %s - %s\n\n' \
    "${C_BLD}${SCRIPT_NAME}${C_RST}" "v$SCRIPT_VERSION" "by $SCRIPT_AUTHOR"

  check_environment
  check_disk_space
  ensure_packages
  cleanup_stale

  install_musl_runtime "$FORCE"
  install_mot          "$FORCE"
  verify_installation
  write_manifest
  print_summary
}

main "$@"
