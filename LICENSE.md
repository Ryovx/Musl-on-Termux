# License

This repository contains two categories of software, licensed differently:

| Part | License | Source |
|---|---|---|
| Patched musl libc source, `ld-musl-aarch64.so.1`, `lib/`, `include/` | **MIT** | Inherited from upstream musl |
| `install.sh`, `mot` runner, CI workflows | **GNU GPLv3 or later** | Original work by Ryovx, derivative of musl |

---

## Part 1 — musl libc (MIT)

The `src/`, `include/`, `arch/`, `crt/`, `ldso/`, `compat/`, `tools/` directories, and any prebuilt `ld-musl-aarch64.so.1`, `lib/*.a`, and header files in this repository are **musl libc**, a modified build of which is distributed here.

musl as a whole is licensed under the following standard MIT license:

    ----------------------------------------------------------------------
    Copyright © 2005-2020 Rich Felker, et al.

    Permission is hereby granted, free of charge, to any person obtaining
    a copy of this software and associated documentation files (the
    "Software"), to deal in the Software without restriction, including
    without limitation the rights to use, copy, modify, merge, publish,
    distribute, sublicense, and/or sell copies of the Software, and to
    permit persons to whom the Software is furnished to do so, subject to
    the following conditions:

    The above copyright notice and this permission notice shall be
    included in all copies or substantial portions of the Software.

    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
    EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
    MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
    IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
    CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
    TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
    SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
    ----------------------------------------------------------------------

The full list of musl authors and third-party notices is preserved in the `COPYRIGHT` file at the root of this repository.

### Modifications to musl

Modifications made by Ryovx (2026) are limited to `src/network/resolvconf.c` and are also released under the MIT license, so the modified musl remains fully MIT-licensed:

    Modifications: Copyright © 2026 Ryovx
    - Added MUSL_ON_TERMUX environment variable support
    - Added DNS fallback order: 1.1.1.1 -> 8.8.8.8 -> 127.0.0.1

For the full upstream license and contributor list, see `COPYRIGHT`.

---

## Part 2 — installer and runner (GNU GPLv3 or later)

The following files are original works by Ryovx, and are derivative works of the musl patch distributed in this repository:

- `install.sh`
- The `mot` runner (the script installed at `$PREFIX/bin/mot`)
- The `mot.template` embedded in `install.sh`
- Any file under `.github/workflows/`
- Any future scripts maintained under `scripts/`

These are licensed under the **GNU General Public License, version 3 or (at your option) any later version**.

### GNU GPLv3 notice

    MoT Installer and Runner
    Copyright © 2026 Ryovx

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <https://www.gnu.org/licenses/>.

The full text of the GNU GPLv3 is available at:

    https://www.gnu.org/licenses/gpl-3.0.txt

A local copy can be obtained with:

    curl -fsSL https://www.gnu.org/licenses/gpl-3.0.txt -o COPYING.GPLv3

### Ethical request (not a legal restriction)

The author kindly requests that you do **not** sell, resell, or bundle this software with any paid product. This is an ethical request, not a legal restriction. Under the GNU GPLv3 you retain the full right to redistribute this software, including commercially, provided you comply with the license terms.

---

## Compatibility between the two licenses

The GNU GPLv3 is compatible with the MIT license. Distributing the musl portion under MIT alongside the installer/runner under GPLv3 does **not** create a licensing conflict:

- The musl runtime (MIT) is a separate, self-contained artifact.
- The installer and runner (GPLv3) **use** the musl runtime but do not incorporate its source into their own.
- Therefore, the MIT terms of the musl runtime are preserved in full, and the GPLv3 terms of the scripts apply only to the scripts themselves.

If you redistribute the repository as a whole, you may do so under the terms of the GNU GPLv3, provided you also preserve the MIT notices for the musl files (which the `COPYRIGHT` file already does).

---

## Disclaimer

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

This project is **not** affiliated with, endorsed by, or sponsored by the musl project, the Termux project, or Anthropic.
