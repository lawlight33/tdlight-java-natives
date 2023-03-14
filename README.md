# Native libraries used by TDLight Java for Apple Silicon (MacOS M1)

This repository is the modification of `tdlight-natives-osx` build scripts to compile them for M1 processor. Used resources:

- [TDLib](https://github.com/tdlib/td)
- [TDLight](https://git.ignuranza.net/tdlight-team/tdlight)
- [TDLight Java](https://github.com/tdlight-team/tdlight-java)
- [dimitree54 Fork](https://github.com/dimitree54/tdlight-java-natives)

You may need it, if you're facing following error:
```
Caused by: it.tdlight.common.utils.CantLoadLibrary: Native libraries for platform OSX-AARCH64 not found! Required version: tdlight osx aarch64 4.0.267
```

After successful compilation `tdlight-natives-osx-aarch64:4.0.0-SNAPSHOT` will be place to you mavenLocal repository (`~/.m2/repository/it/tdlight/tdlight-natives-osx-aarch64/4.0.0-SNAPSHOT`).

To use that natives in `tdlite-java` you need to recompile it as well: https://github.com/dimitree54/tdlight-java

## Compilation

1. Install JDK 1.8, and make it default (`java -version` should print 1.8)
2. Run `scripts/utils./compile-natives-package.sh` for natives
3. Run `./compile-tdapi-package.sh` for tdapi

## Notice

In case of further version changing, don't forget to update source versions of tdlib / tdlight:
1. Put source code of tdlib from [[here]](https://github.com/tdlib/td) to `tdlight-java-natives/implementations/tdlib`. [[current version]](https://github.com/tdlib/td/tree/d48901435017783b5cb91000c29940f9b348158d)
2. Put source code of tdlight from [[here]](https://git.ignuranza.net/tdlight-team/tdlight) to `tdlight-java-natives/implementations/tdlight`. [[current_version]](https://git.ignuranza.net/tdlight-team/tdlight/src/commit/277513ce18c2d08a0d4c314dd23e873412ef54f6)