#!/bin/bash
# Build the qi wheel for the current Python version, on Linux.
# The wheel is generated in ./dist/fixed/
set -euxo pipefail
cd "$(dirname "$0")"

# Build the C++ dependencies (libqi, boost, ...) with Conan, in ./build/conan
bash ci/conan_deps.sh .

# Generate wheel
rm -rf build/wheel
python -m build --wheel --outdir build/wheel \
    --config-setting cmake.define.CMAKE_TOOLCHAIN_FILE="$PWD/build/conan/generators/conan_toolchain.cmake"
wheel=$(ls build/wheel/*.whl)

# Retrieve the platform compatibility for the wheel, using auditwheel show
constraint_tag=$(auditwheel show "$wheel" | grep 'This constrains the platform tag to' | sed -E 's/.*"([^"]+)".*/\1/')

# Repair wheel (using all the dependency libs that have been previously copied by conan)
LD_LIBRARY_PATH="$PWD/build/conan/lib" auditwheel repair --plat "$constraint_tag" -w ./dist/fixed/ "$wheel"
