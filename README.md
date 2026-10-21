# Musl on Termux (MoT)

A patched build of [musl libc](https://musl.libc.org/) for **Termux on Android (aarch64)**, plus `mot` — a small runner that makes it trivial to execute musl-linked binaries natively, without `proot`, `chroot`, `patchelf`, or any container layer.

> **Not an official musl release.** This project is an independent patch set maintained by [Ryovx](https://github.com/Ryovx). It is not endorsed by the musl project or its maintainers. See [Disclaimer](#disclaimer).

---

## Why this exists

Termux runs on Android's **Bionic libc**, not glibc or musl. Binaries linked against `aarch64-linux-musl` (such as the official **Claude Code** `linux-arm64-musl` build) fail to start with:

    cannot execute: required file not found

because the expected interpreter `/lib/ld-musl-aarch64.so.1` does not exist on Android.

`patchelf` was tried and results in `SIGSEGV` on Android kernels. `proot` and `chroot` work, but they break the `bash` tool and add significant overhead.

This project takes a different approach:

1. Ships a **patched musl loader** that reads its DNS configuration from a path Termux can access (`$PREFIX/etc/resolv.conf`), with a deterministic fallback chain.
2. Ships **`mot`**, a tiny runner that invokes the loader with `--library-path` and `LD_PRELOAD` unset, so any musl-linked ELF runs natively.

---

## Install

    curl -fsSL https://raw.githubusercontent.com/Ryovx/Musl-on-Termux/main/install.sh | bash

The installer:

- Verifies the musl archive against a pinned **SHA256**.
- Installs the runtime atomically under `$PREFIX/lib/musl/`.
- Installs `mot` at `$PREFIX/bin/mot`.
- Runs a **5-point verification** before reporting success.

No changes are made to `~/.bashrc` or `~/.zshrc`.

---

## Usage

    mot claude                  # run Claude Code under musl
    mot ./my-binary --help      # run any musl ELF
    mot bash                    # start a bash shell with musl env
    mot zip                     # run a Bionic binary with the musl loader

`mot` inspects the target's ELF `PT_INTERP`:

- `ld-musl-*` → runs via the bundled musl loader (with `MUSL_ON_TERMUX=1`).
- anything else → runs directly (Bionic, `LD_PRELOAD` untouched).

### Management

    mot -i, --install       Install/refresh the musl runtime
    mot -u, --update        Force reinstall (re-download)
    mot -f, --fix           Restore mot from its template
    mot -x, --uninstall     Remove mot and the musl runtime
    mot -h, --help          Full help
    mot -v, --version       Print version

> **After `mot --uninstall`**, the `mot` binary is gone. Reinstall with the `curl` command above.

---

## What changed in musl

The only behavioral change in the musl source is in `src/network/resolvconf.c`:

1. **`MUSL_ON_TERMUX` environment variable**
    - If set to `1`, musl reads its DNS configuration from:

          /data/data/com.termux/files/usr/etc/resolv.conf

      instead of `/etc/resolv.conf`.
    - If unset or `0`, musl behaves exactly like upstream.

2. **Deterministic DNS fallback**
    When no `nameserver` entry is found (or the file is missing), musl tries these in order:

        1.1.1.1  →  8.8.8.8  →  127.0.0.1

    Upstream musl jumps straight to `127.0.0.1`, which has no listener inside Termux, causing `EAI_AGAIN`.

No other musl subsystem is modified. For musl's own changelog, see [`WHATSNEW`](./WHATSNEW).

---

## Prebuilt release

A prebuilt aarch64 runtime is available under [Releases](https://github.com/Ryovx/Musl-on-Termux/releases).

- Tag: `v1.2.6-termux`
- Asset: `musl-on-termux-aarch64.zip`
- SHA256: `e4f456187a54f6fbbcda31026354728262b5acfce11642eaca2df88722c9870b`

Verify the download:

    sha256sum -c musl-on-termux-aarch64.zip.sha256

The archive contains only:

| Path | Description |
|---|---|
| `ld-musl-aarch64.so.1` | musl dynamic loader (also serves as `libc.so`) |
| `lib/` | static archives and crt objects |
| `include/` | musl public headers |

---

## Build provenance

- **Target triple:** `aarch64-linux-musl`
- **Build host:** GitHub Actions `ubuntu-24.04-arm` (native aarch64)
- **Configure:** `./configure --prefix=$PWD/dist --syslibdir=$PWD/dist`
- **Compiler:** system GCC 13.3.0 (Ubuntu 24.04)
- **Reproducible:** yes, from the corresponding source tag

---

## License

This repository ships **two licenses**, one per part:

| Part | License | File |
|---|---|---|
| Patched musl source, `ld-musl-aarch64.so.1`, `lib/`, `include/` | **MIT** (inherits from upstream musl) | `COPYRIGHT`, `LICENSE` |
| `install.sh`, `mot` runner, CI workflows | **GNU GPLv3 or later** | `LICENSE` |

The `mot` runner and `install.sh` are derivative works of the musl patch and are therefore released under **GPLv3** as a whole. The musl runtime itself remains **MIT** — the same license it has always had.

See [`LICENSE`](./LICENSE) for the full text.

---

## Contributing

Issues and PRs are welcome.

- **Bug reports:** open an issue with the exact `mot` / `install.sh` version and the failing command.
- **Patches:** fork, make your changes against the `main` branch, and open a PR.
- **Translations of this README:** welcome; open a PR adding `README.<lang>.md`.

Please do **not** file musl bugs here — report them upstream at https://musl.libc.org/.

---

## Disclaimer

This is **not** an official musl release. It is not endorsed by the musl project or its maintainers.

"musl" is used descriptively to identify the upstream codebase from which this build is derived. "Termux" is used descriptively to identify the target runtime environment.

**The software is provided "AS IS", without warranty of any kind.** See `LICENSE` for the full disclaimer.

---

## Upstream

- musl project: https://musl.libc.org/
- musl source: https://git.musl-libc.org/git/musl
- Termux: https://termux.dev/
- Claude Code: https://docs.anthropic.com/en/docs/claude-code

---

*Built with ❤️ for the Termux community.*
