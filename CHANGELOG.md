# Changelog

All notable changes to **this patch set** are documented here.

> **Note:** This file is **not** the upstream musl changelog.
>
> - **`CHANGELOG.md`** (this file) documents:
>   - the changes to `src/network/resolvconf.c` (the patch),
>   - the `mot` runner,
>   - the `install.sh` installer.
>
> - **`WHATSNEW`** (upstream file, unmodified) documents:
>   - the changes to musl libc itself, as published by the musl project.
>   - If you want the history of musl's own code, read `WHATSNEW`.
>
> Keep these two files separate. Do not add musl upstream changes here.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html)
for the `mot` runner.

---

## [mot 1.3.2] — 2026-10-21

### Fixed
- **`mot` builtins:** replaced the fragile `exec bash -c '"$@"' _ "$cmd" "$@"` pattern with `command "$cmd" "$@"`. Builtins like `echo`, `cd`, `pwd`, `true`, `false`, and shell functions now execute in the current shell with the correct exit code, and no longer produce `bash: line N: ...: No such file or directory`.
- **`mot` exec semantics:** removed `exec` from `run_command`, so `mot` propagates the target's exit status and its own `trap` (if any) fires normally.
- **Bionic path translation:** `mot` no longer unsets `LD_PRELOAD` for Bionic binaries. Only musl binaries run with `env -u LD_PRELOAD`, so `termux-exec` continues to translate absolute paths like `/etc` and `/tmp` for shell tools, `ls`, `zip`, etc.
- **`--library-path`:** reduced from `"$MUSL:$MUSL/lib"` to `"$MUSL"`, matching the actual archive layout.

### Changed
- `pkg install readelf` replaced with `pkg install binutils` — `readelf` is not a package name in Termux.
- `verify_installation` now checks the exit code of every probe explicitly.
- Heredoc delimiters renamed to `__MOT_SCRIPT_END__` / `__MOT_USAGE_END__` to avoid collision with shell builtins or user input.
- `cleanup_work` is now safe under `set -u`.

### Added
- `mot --` (explicit separator) now handles zero arguments cleanly.
- `mot --install` and `mot --update` reject unexpected arguments.
- `cmd_fix` verifies the restored binary before reporting success.

### Versions
- `install.sh` 1.3.2
- `mot` 1.3.2
- musl runtime 1.2.6 (patched)

---

## [mot 1.3.1] — 2026-10-21

### Fixed
- `install.sh` now verifies the SHA256 of the musl archive before extraction (this was missing in 1.3.0's installer path).
- `mot` accepts `-i` / `--install` as explicit no-ops on the installer side.
- `install.sh` refuses to uninstall outside a `*/com.termux/files/usr` prefix.

### Added
- `assert_termux_prefix` guard on both `install.sh` and `mot --uninstall`.

---

## [mot 1.3.0] — 2026-10-21

### Added
- First public release of the `mot` runner.
- `mot <cmd>` executes any musl ELF using the bundled loader.
- `mot -i` / `-u` / `-f` / `-x` management subcommands.
- Atomic install: musl runtime and `mot` are swapped into place, with rollback on failure.
- Manifest at `$PREFIX/lib/musl/.install-manifest` for version tracking.
- Template at `$PREFIX/lib/musl/mot.template` for `mot --fix`.

### Notes
- `mot 1.3.0` and `1.3.1` had issues with builtin dispatch (`exec bash -c` pattern) and with Bionic `LD_PRELOAD`. Both are fixed in `1.3.2`.

---

## [musl 1.2.6-termux] — 2026-10-21

### Added
- `MUSL_ON_TERMUX` environment variable. When set to `1`, `resolvconf.c` reads its DNS configuration from `/data/data/com.termux/files/usr/etc/resolv.conf` instead of `/etc/resolv.conf`.
- Deterministic DNS fallback chain: `1.1.1.1` → `8.8.8.8` → `127.0.0.1`. Upstream jumps straight to `127.0.0.1`, which has no listener in Termux.

### Changed
- `src/network/resolvconf.c` only. No other musl subsystem is modified.

### Build
- Target: `aarch64-linux-musl`
- Host: GitHub Actions `ubuntu-24.04-arm`
- Compiler: GCC 13.3.0
- Release asset: `musl-on-termux-aarch64.zip`
- SHA256: `e4f456187a54f6fbbcda31026354728262b5acfce11642eaca2df88722c9870b`

### Notes
- For musl's own history before this patch, see [`WHATSNEW`](./WHATSNEW).
- This release is based on **musl 1.2.6**.

---

## For musl's own changelog

The full upstream changelog is available in the [`WHATSNEW`](./WHATSNEW) file at the root of this repository. It is unmodified from upstream musl.

If you need to know what changed in musl libc itself between `1.2.5` and `1.2.6`, read `WHATSNEW`. Do **not** read this file for that purpose — `CHANGELOG.md` only tracks the patches and tools maintained by this repository.
