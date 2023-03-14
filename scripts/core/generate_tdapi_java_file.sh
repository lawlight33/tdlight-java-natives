#!/bin/bash -e
# MAIN REQUIRED ENVIRONMENT VARIABLES:
#   OPERATING_SYSTEM_NAME = <windows | linux | osx>
#   CPU_ARCHITECTURE_NAME = <amd64 | aarch64 | 386 | s390x | armhf | ppc64le>
#   IMPLEMENTATION_NAME = <tdlib | tdlight>
#   API_TYPE = <legacy | sealed>
#   CPU_CORES = "-- -j<cores>" or "-m" on Windows
# OTHER REQUIRED ENVIRONMENT VARIABLES:
#   CMAKE_EXTRA_ARGUMENTS = <args>

# Check variables correctness
if [ -z "${OPERATING_SYSTEM_NAME}" ]; then
	echo "Missing parameter: OPERATING_SYSTEM_NAME"
	exit 1
fi
if [ -z "${CPU_ARCHITECTURE_NAME}" ]; then
	echo "Missing parameter: CPU_ARCHITECTURE_NAME"
	exit 1
fi
if [ -z "${IMPLEMENTATION_NAME}" ]; then
	echo "Missing parameter: IMPLEMENTATION_NAME"
	exit 1
fi
if [ -z "${API_TYPE}" ]; then
	echo "Missing parameter: API_TYPE"
	exit 1
fi
if [ -z "${CPU_CORES}" ]; then
	echo "Missing parameter: CPU_CORES"
	exit 1
fi

source ./setup-variables.sh

if [[ "$API_TYPE" == "sealed" ]]; then
	MIN_JDK_VERSION="17"
	SEALED="true"
else
	MIN_JDK_VERSION="8"
	SEALED="false"
fi

cd ../../
JAVA_API_PACKAGE_PATH="it/tdlight/jni"
JAVA_LIB_PACKAGE_PATH="it/tdlight/tdnative"

# Print details
echo "Generating TdApi.java..."
echo "Current directory: $(pwd)"
echo "Operating system: ${OPERATING_SYSTEM_NAME}"
echo "Architecture: ${CPU_ARCHITECTURE_NAME}"
echo "Td implementation: ${IMPLEMENTATION_NAME}"
echo "API type: ${API_TYPE}"
echo "Min jdk version: ${MIN_JDK_VERSION}"
echo "Sealed: ${SEALED}"
echo "CPU cores count: ${CPU_CORES}"
echo "CMake extra arguments: '${CMAKE_EXTRA_ARGUMENTS}'"
echo "JAVA_API_PACKAGE_PATH: '${JAVA_API_PACKAGE_PATH}'"
echo "JAVA_LIB_PACKAGE_PATH: '${JAVA_LIB_PACKAGE_PATH}'"

# Setup constants
if [[ "$OPERATING_SYSTEM_NAME" == "windows" ]]; then
	export PYTHON_EXECUTABLE="python"
else
	export PYTHON_EXECUTABLE="python3"
fi

# Delete old data
echo "Deleting old data..."
[ -d ./generated-"$API_TYPE"/tdjni_build/ ] && rm -r ./generated-"$API_TYPE"/tdjni_build/
[ -d ./generated-"$API_TYPE"/tdjni_bin/ ] && rm -r ./generated-"$API_TYPE"/tdjni_bin/
[ -d ./generated-"$API_TYPE"/tdjni_docs/ ] && rm -r ./generated-"$API_TYPE"/tdjni_docs/
[ -f ./generated-"$API_TYPE"/src/main/java17/${JAVA_API_PACKAGE_PATH}/TdApi.java ] && rm ./generated-"$API_TYPE"/src/main/java17/${JAVA_API_PACKAGE_PATH}/TdApi.java
[ -f ./generated-"$API_TYPE"/src/main/java/${JAVA_API_PACKAGE_PATH}/TdApi.java ] && rm ./generated-"$API_TYPE"/src/main/java/${JAVA_API_PACKAGE_PATH}/TdApi.java

# Create missing folders
echo "Creating missing folders..."
[ -d "./generated-$API_TYPE/src/main/java/${JAVA_API_PACKAGE_PATH}/" ] || mkdir -p "./generated-$API_TYPE/src/main/java/${JAVA_API_PACKAGE_PATH}/"
[ -d "./generated-$API_TYPE/src/main/java/${JAVA_LIB_PACKAGE_PATH}/" ] || mkdir -p "./generated-$API_TYPE/src/main/java/${JAVA_LIB_PACKAGE_PATH}/"
[ -d ./generated-"$API_TYPE"/tdjni_build/ ] || mkdir ./generated-"$API_TYPE"/tdjni_build/
[ -d ./generated-"$API_TYPE"/tdjni_bin/ ] || mkdir ./generated-"$API_TYPE"/tdjni_bin/
[ -d ./generated-"$API_TYPE"/tdjni_docs/ ] || mkdir ./generated-"$API_TYPE"/tdjni_docs/

# Copy executables
echo "Copying executables..."

if [[ "$OPERATING_SYSTEM_NAME" == "windows" ]]; then
	TD_GENERATED_BINARIES_DIR="$(realpath ./generated/td_tools/td/generate/Release)"
else
	TD_GENERATED_BINARIES_DIR="$(realpath ./generated/td_tools/td/generate)"
fi
export TD_GENERATED_BINARIES_DIR

# Configure cmake
echo "Configuring CMake..."
cd ./generated/
echo "Telegram source path: '$(realpath ./implementation/)'"

# Run cmake to generate TdApi.java
echo "Generating TdApi.java..."
./td_tools/td/generate/td_generate_java_api TdApi "./implementation/td/generate/scheme/td_api.tlo" "../generated-$API_TYPE/src/main/java" "$JAVA_API_PACKAGE_PATH"
php ./implementation/td/generate/JavadocTlDocumentationGenerator.php "./implementation/td/generate/scheme/td_api.tl" "../generated-$API_TYPE/src/main/java/${JAVA_API_PACKAGE_PATH}/TdApi.java"
mv "../generated-$API_TYPE/src/main/java/${JAVA_API_PACKAGE_PATH}/TdApi.java" "../generated-$API_TYPE/src/main/java/${JAVA_API_PACKAGE_PATH}/php_TdApi.java"

echo "Patching TdApi.java for Java ${MIN_JDK_VERSION}..."
${PYTHON_EXECUTABLE} ../scripts/core/tdlib-serializer "$(realpath  ../generated-"$API_TYPE"/src/main/java/${JAVA_API_PACKAGE_PATH}/php_TdApi.java)" "$(realpath ../generated-"$API_TYPE"/src/main/java/${JAVA_API_PACKAGE_PATH}/unexpanded_TdApi.java)" "$(realpath ../scripts/core/tdlib-serializer/headers.txt)" "$SEALED"
if [[ "$OPERATING_SYSTEM_NAME" == "osx" ]]; then
	unexpand --tabs=2 ../generated-"$API_TYPE"/src/main/java/${JAVA_API_PACKAGE_PATH}/unexpanded_TdApi.java > ../generated-"$API_TYPE"/src/main/java/${JAVA_API_PACKAGE_PATH}/TdApi.java
else
	unexpand -t 2 ../generated-"$API_TYPE"/src/main/java/${JAVA_API_PACKAGE_PATH}/unexpanded_TdApi.java > ../generated-"$API_TYPE"/src/main/java/${JAVA_API_PACKAGE_PATH}/TdApi.java
fi
rm ../generated-"$API_TYPE"/src/main/java/${JAVA_API_PACKAGE_PATH}/unexpanded_TdApi.java

echo "Generated '$(realpath ../generated-"$API_TYPE"/src/main/java/${JAVA_API_PACKAGE_PATH}/TdApi.java)'"


rm ../generated-"$API_TYPE"/src/main/java/${JAVA_API_PACKAGE_PATH}/php_TdApi.java

echo "Done."
exit 0
