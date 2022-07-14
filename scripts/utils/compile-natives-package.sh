#!/bin/bash -e
# This script compiles tdlight/tdlib jni binaries for your platform.
# Fill the variables with your system details.
#

# copy paste src/main/replacements/replace-osx-amd64-tdlight-legacy.sed
# and src/main/replacements/replace-osx-amd64-tdlight-sealed.sed
# to src/main/replacements/replace-osx-aarch64-tdlight-legacy.sed and
# src/main/replacements/replace-osx-aarch64-tdlight-sealed.sed
# (and replace "amd64" with "aarch64" inside)

# MAIN REQUIRED ENVIRONMENT VARIABLES:
brew install maven
brew install openssl
brew install coreutils
export OPENSSL_ROOT_DIR="/opt/homebrew/opt/openssl@3"
export OPERATING_SYSTEM_NAME="osx"
export CPU_ARCHITECTURE_NAME="aarch64"
export OPERATING_SYSTEM_NAME_SHORT="osx"
export IMPLEMENTATION_NAME="tdlight"
export CPU_CORES="-- -j8"
export REVISION=1
export BUILD_TYPE="Release"
# OPTIONAL ENVIRONMENT VARIABLES:
#   CROSS_BUILD_DEPS_DIR = <args>

cd ../core

source ./setup-variables.sh
./install-dependencies.sh
./generate_maven_project.sh
./generate_td_tools.sh
./configure_td.sh
./compile_td.sh
./compile_tdjni.sh
./build_generated_maven_project.sh

echo "Done."
exit 0
