# musl libc (patched for Termux/Android)

This is a modified build of [musl libc](https://musl.libc.org/) for
**Termux on Android (aarch64)**. It is **not** an official musl build
and is **not** endorsed by the musl project.

## What changed

The only behavioral change is in `src/network/resolvconf.c`:

1. **MUSL_ON_TERMUX environment variable**
    - If set to `1`, musl reads DNS configuration from
      `/data/data/com.termux/files/usr/etc/resolv.conf`
      instead of `/etc/resolv.conf`.
    - If unset (or `0`), musl uses `/etc/resolv.conf` as upstream.

2. **DNS fallback order**
    When no `nameserver` is found (or `resolv.conf` is missing), musl
    tries these in order before giving up:
    
        1.1.1.1  →  8.8.8.8  →  127.0.0.1

This is required because Android's Bionic libc routes DNS through the
`netd` service, and `/etc/resolv.conf` is not readable inside Termux
by default. Without this patch, musl falls back to `127.0.0.1:53`
(which has no listener), causing `EAI_AGAIN` errors.

## Build

Built natively on `aarch64` with target: `aarch64-linux-musl`.

## What's inside

| File | Purpose |
|---|---|
| `ld-musl-aarch64.so.1` | musl dynamic loader (also serves as `libc.so`) |
| `lib/` | static libs (`libc.a`, `libm.a`, …), crt objects |
| `include/` | musl public headers |

## License

MIT. See `COPYRIGHT` for the original musl license and the full list
of authors and third-party notices.

## Links

- musl: https://musl.libc.org/
- Source: https://git.musl-libc.org/git/musl
