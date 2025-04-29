#!/bin/bash
conan profile detect

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

# Repair wheel (using all the dependency libs that have been previously copied by conan)
DYLD_LIBRARY_PATH=$PWD/build/macos-armv8-apple-clang-release/lib delocate-wheel -w ./dist/fixed/ --check-archs  ./dist/qi-3.1.6-cp313-cp313-macosx_15_0_arm64.whl
