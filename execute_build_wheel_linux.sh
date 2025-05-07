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
cmake --list-presets # => it should list the preset "conan-linux-x86_64-gcc-release"
cmake --preset conan-linux-x86_64-gcc-release
cmake --build --preset conan-linux-x86_64-gcc-release -j8

# Generate wheel
python -m build --config-setting cmake.define.CMAKE_TOOLCHAIN_FILE=$PWD/build/linux-x86_64-gcc-release/generators/conan_toolchain.cmake

# Retrieve python version as "3Y" for 3.Y.Z ("313" for python 3.13.Z)
python_version=$(python --version 2>&1 | awk '{print $2}' | cut -d'.' -f1,2 | sed 's/\.//g')
# Retrieve the platform compatibility for the wheel, using auditwheel show
constraint_tag=$(auditwheel show ./dist/qi-3.1.6-cp${python_version}-cp${python_version}-linux_x86_64.whl | grep 'This constrains the platform tag to' | sed -E 's/.*"([^"]+)".*/\1/')

# Repair wheel (using all the dependency libs that have been previously copied by conan)
LD_LIBRARY_PATH=$PWD/build/linux-x86_64-gcc-release/lib/ auditwheel repair --strip --plat ${constraint_tag} dist/qi-3.1.6-cp${python_version}-cp${python_version}-linux_x86_64.whl -w ./dist/fixed/
