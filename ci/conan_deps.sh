#!/bin/bash
# Build the C++ dependencies of the qi Python module (libqi, boost, openssl, ...)
# with Conan.
#
# Usage: ci/conan_deps.sh [PROJECT_DIR]
#
# The dependencies do not depend on the Python version, so this only needs to
# be run once before building the wheels for any number of Python versions.
# It produces, in PROJECT_DIR/build/conan:
#   - generators/conan_toolchain.cmake: the CMake toolchain to build the wheel.
#   - lib/ (bin/ on Windows): the dependencies shared libraries, needed to
#     repair the wheel (auditwheel on Linux, delocate on macOS, delvewheel on
#     Windows).
#
# Environment variables:
#   QI_REPOSITORY             libqi git repository.
#   QI_VERSION                libqi version, cloned from tag "qi-framework-v<QI_VERSION>".
#   QI_REF                    libqi git branch or tag to clone instead (e.g. to test a
#                             libqi branch), still exported as version QI_VERSION.
#   CONAN_BUILD               value of `conan install --build` (default: "missing").
#   MACOSX_DEPLOYMENT_TARGET  (macOS only) minimum macOS version of the wheel
#                             (default: "11.0").

set -euxo pipefail

PROJECT_DIR=$(cd "${1:-$(dirname "$0")/..}" && pwd)
QI_REPOSITORY=${QI_REPOSITORY:-https://github.com/funwithagents/libqi.git}
QI_VERSION=${QI_VERSION:-4.0.8}
QI_REF=${QI_REF:-qi-framework-v${QI_VERSION}}
QI_PATH="$PROJECT_DIR/build/libqi"

# Clone libqi and load its conanfile into the Conan cache.
rm -rf "$QI_PATH"
git clone --depth=1 --branch "$QI_REF" "$QI_REPOSITORY" "$QI_PATH"
conan profile detect --exist-ok
conan export "$QI_PATH" --version "$QI_VERSION"

case "$(uname)" in
    # MSVC does not support the GNU extensions.
    MINGW*|MSYS*|CYGWIN*) cppstd=17 ;;
    *) cppstd=gnu17 ;;
esac

conan_args=(
    --build="${CONAN_BUILD:-missing}"
    -s build_type=Release
    -s compiler.cppstd="$cppstd"
    -c tools.build:skip_test=true
    -c '&:tools.build:skip_test=true'
    # Retry longer when downloading the sources of a dependency (e.g. from
    # github.com) fails: 5 times, every 20s (instead of 2 times, every 5s).
    -c tools.files.download:retry=5
    -c tools.files.download:retry_wait=20
    # Use a fixed build folder ("build/conan") whatever the platform, so that
    # the paths to the toolchain and to the libraries are known in advance.
    -c "tools.cmake.cmake_layout:build_folder_vars=['const.conan', '!settings.build_type']"
)
if [[ "$(uname)" == "Darwin" ]]; then
    # Build the dependencies for the same minimum macOS version as the wheel,
    # otherwise delocate refuses to bundle them in the wheel.
    conan_args+=(-s "os.version=${MACOSX_DEPLOYMENT_TARGET:-11.0}")
fi

conan install "$PROJECT_DIR" "${conan_args[@]}"
