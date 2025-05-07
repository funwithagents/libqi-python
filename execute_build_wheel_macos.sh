#!/bin/bash

# Set needed variables for libqi repository dependency
QI_REPOSITORY="https://github.com/funwithagents/libqi.git"
QI_VERSION="4.0.5"
QI_PATH="$PWD/../libqi"
rm -rf $QI_PATH
# Clone liqi respository
git clone --depth=1 --branch "qi-framework-v${QI_VERSION}" "${QI_REPOSITORY}" "${QI_PATH}"
# Link the libqi dependency by loading its conanfile into conan cache 
conan export "${QI_PATH}" --version "${QI_VERSION}" 

# Build
conan install . --build=missing -c tools.build:skip_test=true -c '&:tools.build:skip_test=true'
cmake --list-presets # => it should list the preset "conan-macos-armv8-apple-clang-release"
cmake --preset conan-macos-armv8-apple-clang-release
cmake --preset conan-macos-armv8-apple-clang-release
# Generate wheel
python -m build --config-setting cmake.define.CMAKE_TOOLCHAIN_FILE=$PWD/build/macos-armv8-apple-clang-release/generators/conan_toolchain.cmake

# Retrieve python version as "3Y" for 3.Y.Z ("313" for python 3.13.Z)
python_version=$(python --version 2>&1 | awk '{print $2}' | cut -d'.' -f1,2 | sed 's/\.//g')
# Retrieve macOS major version
macos_version=$(sw_vers -productVersion)
macos_major_version=$(echo $macos_version | cut -d'.' -f1)

# Repair wheel (using all the dependency libs that have been previously copied by conan)
DYLD_LIBRARY_PATH=$PWD/build/macos-armv8-apple-clang-release/lib delocate-wheel -w ./dist/fixed/ --check-archs  ./dist/qi-3.1.6-cp${python_version}-cp${python_version}-macosx_${macos_major_version}_0_arm64.whl
