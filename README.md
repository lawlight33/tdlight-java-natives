# Native libraries used by TDLight Java for Mac OS AARCH64

This repository generates JNI packages for each architecture and OS used by [TDLight Java](https://github.com/tdlight-team/tdlight-java).

In that repository I publish settings and some workaround that helped me to compile tdlight-java natives for M1 processor.
Check `./compile-natives-package.sh` and its comments

## Building

Go to `scripts/utils` and run

- `./compile-natives-package.sh` for natives

- `./compile-tdapi-package.sh` for tdapi

## Download

Download the latest release of [TDLight Java](https://github.com/tdlight-team/tdlight-java/releases)

If you want to download directly the native packages for each architecture and os, go to Actions tab and click on the latest build.
