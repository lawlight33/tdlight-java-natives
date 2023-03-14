#!/bin/bash -e
# MAIN REQUIRED ENVIRONMENT VARIABLES:
#   OPERATING_SYSTEM_NAME = <windows | linux | osx>
#   CPU_ARCHITECTURE_NAME = <amd64 | aarch64 | 386 | s390x | armhf | ppc64le>
#   IMPLEMENTATION_NAME = <tdlib | tdlight>
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
if [ -z "${CPU_CORES}" ]; then
	echo "Missing parameter: CPU_CORES"
	exit 1
fi

source ./setup-variables.sh

cd ../../

# Print details
echo "Generating td tools..."
echo "Current directory: $(pwd)"
echo "Operating system: ${OPERATING_SYSTEM_NAME}"
echo "Architecture: ${CPU_ARCHITECTURE_NAME}"
echo "Td implementation: ${IMPLEMENTATION_NAME}"
echo "CPU cores count: ${CPU_CORES}"
echo "CMake extra arguments: '${CMAKE_EXTRA_ARGUMENTS}'"

# Delete old data
echo "Deleting old data..."
[ -d ./generated/implementation/ ] && rm -r ./generated/implementation/
[ -d ./generated/td_tools/ ] && rm -r ./generated/td_tools/

# Create missing folders
echo "Creating missing folders..."
[ -d "./generated" ] || mkdir "./generated"

# Copy implementation files
echo "Copying implementation files..."
cp -r implementations/${IMPLEMENTATION_NAME} ./generated/implementation

# Patch implementation files (sed replacements)
echo "Patching implementation files using sed replacements..."
#Fix bug: https://github.com/tdlib/td/issues/1238
if [[ "$IMPLEMENTATION_NAME" = "tdlib" ]]; then
	if [[ "$OPERATING_SYSTEM_NAME" = "osx" ]]; then
		sed -f "src/main/replacements/fix-tdlib-tdutils-windows-cmake.sed" -i "" ./generated/implementation/tdutils/CMakeLists.txt
	else
		sed -f "src/main/replacements/fix-tdlib-tdutils-windows-cmake.sed" -i"" ./generated/implementation/tdutils/CMakeLists.txt
	fi
fi

# Patch implementation files (git patches)
echo "Patching implementation files using git patches..."
if [[ "$IMPLEMENTATION_NAME" = "tdlib" ]]; then
  if [[ -d "src/main/patches/tdlib" && "$(ls -A src/main/patches/tdlib)" ]]; then
    git apply --directory="generated/implementation" src/main/patches/tdlib/*.patch
  fi
fi
if [[ "$IMPLEMENTATION_NAME" = "tdlight" ]]; then
  if [[ -d "src/main/patches/tdlight" && "$(ls -A src/main/patches/tdlight)" ]]; then
    git apply --directory="generated/implementation" src/main/patches/tdlight/*.patch
  fi
fi

# Configure cmake
echo "Configuring CMake..."
mkdir ./generated/td_tools/
cd ./generated/td_tools/
cmake -DCMAKE_BUILD_TYPE=Release -DTD_ENABLE_JNI=ON ${CMAKE_EXTRA_ARGUMENTS} ../implementation/

# Run cmake to generate common tools
echo "Generating cross compilation tools..."
cmake --build . --target prepare_cross_compiling --config Release ${CPU_CORES}

# Run cmake to generate java tools
echo "Generating java tools..."
cmake --build . --target td_generate_java_api --config Release ${CPU_CORES}

# Copy tlo files
echo "Copying *.tlo files..."
cp -r ../implementation/td/generate/auto/tlo/. ../implementation/td/generate/scheme/.


echo "Generated executable '$(realpath ./td/generate/generate_common)'"
echo "Generated executable '$(realpath ./td/generate/td_generate_java_api)'"
echo "Generated executable '$(realpath ./td/generate/generate_json)'"
echo "Generated executable '$(realpath ../implementation/td/generate/JavadocTlDocumentationGenerator.php)'"
echo "Generated executable '$(realpath ../implementation/td/generate/TlDocumentationGenerator.php)'"
echo "Generated executable '$(realpath ../implementation/td/generate/scheme/td_api.tl)'"
echo "Generated executable '$(realpath ../implementation/td/generate/scheme/td_api.tlo)'"

echo "Done."
exit 0
