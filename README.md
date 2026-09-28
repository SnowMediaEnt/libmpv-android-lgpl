# libmpv for Android — LGPL build

**LGPL build for Tronix; this repository is the source of the libmpv used in Tronix.**

A fork of [jarnedemeulemeester/libmpv-android](https://github.com/jarnedemeulemeester/libmpv-android)
(itself based on [mpv-android](https://github.com/mpv-android/mpv-android)) at tag `v0.5.1`
(mpv 0.40.0, FFmpeg 7.1.1), rebuilt so that **no GPL code** is compiled in. The Java API
(`dev.jdtech.mpv.MPVLib`) is unchanged, so it is a drop-in replacement for
`dev.jdtech.mpv:libmpv:0.5.1`.

Built AARs and the complete corresponding source (every library's source, after patches,
plus these build scripts) are attached to each
[release](https://github.com/SnowMediaEnt/libmpv-android-lgpl/releases).

## Changes from upstream (branch `lgpl`)

| Where | Upstream | This fork |
|---|---|---|
| `buildscripts/scripts/ffmpeg.sh` | `--enable-gpl --enable-version3` | `--enable-version3 --disable-gpl --disable-nonfree --disable-postproc`; the build fails unless FFmpeg reports `LGPL version 3 or later` |
| `buildscripts/scripts/ffmpeg.sh` | ships `libpostproc.so` (GPL-only) | not built, not shipped |
| `buildscripts/scripts/mpv.sh` | mpv default `-Dgpl=true` | `-Dgpl=false`; the build fails unless `HAVE_GPL` is 0 |
| `buildscripts/build.sh`, `libmpv/build.gradle.kts` | armeabi-v7a, arm64-v8a, x86, x86_64 | armeabi-v7a, arm64-v8a only |
| `.github/workflows/build.yaml` | build only | build, then check every `.so` in the AAR (FFmpeg configuration and license strings, mpv configuration) and fail on any GPL marker; tags `lgpl-v*` publish a release with the AAR and a source archive |
| `.github/workflows/publish.yaml` | Maven Central publishing | removed |

`--enable-version3` stays because FFmpeg requires it for mbedtls (Apache-2.0); it makes
FFmpeg LGPL version 3 or later rather than 2.1 or later. Nothing else in the build is GPL.

## License

The native libraries in the AAR, as a whole, are distributed under the
**GNU Lesser General Public License, version 3 or later** (FFmpeg's terms; mpv and the other
LGPL parts are LGPL-2.1-or-later, which is compatible). Texts: [LICENSES/LGPL-3.0.txt](LICENSES/LGPL-3.0.txt)
(which incorporates [LICENSES/GPL-3.0.txt](LICENSES/GPL-3.0.txt)) and
[LICENSES/LGPL-2.1.txt](LICENSES/LGPL-2.1.txt).

| Component | Version | License |
|---|---|---|
| mpv (`libmpv.so`, built with `-Dgpl=false`) | 0.40.0 | LGPL-2.1-or-later |
| FFmpeg (`libav*.so`, `libswresample.so`, `libswscale.so`, no `--enable-gpl`) | 7.1.1 | LGPL-3.0-or-later |
| libplacebo | 7.351.0 | LGPL-2.1-or-later |
| FriBidi | 1.0.16 | LGPL-2.1-or-later |
| libass | 0.17.4 | ISC |
| FreeType | 2.13.3 | FreeType License (FTL), chosen from its FTL / GPL-2.0 dual license |
| HarfBuzz | 11.2.1 | MIT ("Old MIT") |
| dav1d | 1.5.1 | BSD-2-Clause |
| Mbed TLS | 3.6.4 | Apache-2.0, chosen from its Apache-2.0 / GPL-2.0-or-later dual license |
| Lua | 5.2.4 | MIT |
| LLVM libc++ (`libc++_shared.so`, from the Android NDK) | NDK 28.2 | Apache-2.0 WITH LLVM-exception |
| JNI wrapper (`libplayer.so`, `MPVLib.java`) | — | MIT, see [LICENSE](LICENSE) |

Portions of this software are copyright © The FreeType Project (www.freetype.org). All rights reserved.

## Building from source

Take a look at [README.md](buildscripts/README.md) inside the `buildscripts` directory, or run the
`Build libmpv-android (LGPL)` workflow. In short:

```shell
cd buildscripts
./download.sh && ./patch.sh && ./build.sh
# AAR: libmpv/build/outputs/aar/libmpv-release.aar
```

To replace the libraries in an application that uses this AAR, build your own modified copy
with the same scripts and put its `.so` files in place of the ones in the APK (the libraries are
dynamically linked shared objects).
