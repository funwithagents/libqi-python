#!/bin/bash
# Build the qi wheel for the current Python version, on macOS.
# The wheel is generated in ./dist/fixed/
set -euxo pipefail
cd "$(dirname "$0")"

# Minimum macOS version supported by the wheel (and its dependencies)
export MACOSX_DEPLOYMENT_TARGET=${MACOSX_DEPLOYMENT_TARGET:-11.0}

# Build the C++ dependencies (libqi, boost, ...) with Conan, in ./build/conan
bash ci/conan_deps.sh .

# Generate wheel
rm -rf build/wheel
python -m build --wheel --outdir build/wheel \
    --config-setting cmake.define.CMAKE_TOOLCHAIN_FILE="$PWD/build/conan/generators/conan_toolchain.cmake"
wheel=$(ls build/wheel/*.whl)

# Repair wheel (using all the dependency libs that have been previously copied by conan)
DYLD_LIBRARY_PATH="$PWD/build/conan/lib" delocate-wheel --check-archs -w ./dist/fixed/ "$wheel"
