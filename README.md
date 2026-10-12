# qi package - Python binding for Libqi

> ⚠️ **Unofficial fork.** This repository is a community fork of
> [aldebaran/libqi-python](https://github.com/aldebaran/libqi-python). It is **not affiliated
> with, endorsed by, or supported by** Aldebaran, SoftBank Robotics or United Robotics Group.
> It is maintained on a best-effort basis: fixes are made when I need them, with no
> guarantee of support or updates. NAO and Pepper are trademarks of their respective owners.

This repository contains the Python bindings of [LibQi](https://github.com/funwithagents/libqi), the library used to communicate with robots using Naoqi (Nao & Pepper).

These LibQi python bindings correspond to the  `qi` Python module.

## Up-to-date repository for compatibility with recent Python versions and OS

- This repository is a fork of the official [libqi-python](https://github.com/aldebaran/libqi-python) repository (that seems to be not maintained by Aldebaran anymore).
- I created it mainly to update the code of the package to be able to build it with recent versions of Python (3.10+) on MacOS and Linux

## Pre-built packages

- These wheels are built from this fork and are **not** the official `qi` package published on PyPI by Aldebaran.
- Check the [Releases](https://github.com/funwithagents/libqi-python/releases) to directly retrieve python wheels compatible with recent version of Python, for Linux, MacOS and Windows
- Available wheels (built by GitHub Actions, see below)
    - Python 3.10 to 3.15
    - Linux x86_64, with glibc 2.28+ (Ubuntu 20.04+, Debian 10+, RHEL 8+, ...): `manylinux_2_28_x86_64`
    - MacOS 11+ on Apple Silicon: `macosx_11_0_arm64`
    - Windows x64: `win_amd64` (the MSVC C++ runtime is included in the wheel)

### Installing the wheels

The wheels are listed in a package index hosted on GitHub Pages: https://funwithagents.github.io/libqi-python/simple/ (the wheels themselves are downloaded from the GitHub Releases). pip and uv pick the wheel matching your Python version and OS.

With **uv**, in the `pyproject.toml` of your project:

```toml
[project]
dependencies = ["qi==3.1.7"]

[[tool.uv.index]]
name = "funwithagents"
url = "https://funwithagents.github.io/libqi-python/simple/"
explicit = true  # only used for the packages below

[tool.uv.sources]
qi = { index = "funwithagents" }
```

`explicit = true` makes uv take `qi` only from this index, never from PyPI (where the official `qi` package of Aldebaran is published).

With **pip**:

```bash
pip install "qi==3.1.7" --extra-index-url https://funwithagents.github.io/libqi-python/simple/
```

⚠️ Always pin the version with pip: it looks for `qi` in both PyPI and this index, and installs the highest version found.

You can also download a wheel from the [Releases](https://github.com/funwithagents/libqi-python/releases) and install it with `pip install path/to/wheel.whl`.

## Continuous integration and releases

The wheels are built by the [Wheels](.github/workflows/wheels.yml) GitHub Actions workflow, with [cibuildwheel](https://cibuildwheel.pypa.io) (configured in `pyproject.toml`):
- on pull requests to `master` changing build-related files, and on manual runs ("Run workflow" in the Actions tab): the wheels are available as artifacts of the run
- on tags `v*`: the wheels are also attached to a GitHub Release (a tag with a suffix, like `v3.1.7-rc1`, creates a pre-release)
- after a release (except pre-releases), the [Package index](.github/workflows/index.yml) workflow regenerates the package index from all the releases (`ci/generate_index.py`) and deploys it to GitHub Pages. Run it manually after editing or deleting a release.

The C++ dependencies (libqi, boost, openssl, ...) are built once per platform with Conan by `ci/conan_deps.sh`, then reused for all Python versions. Each wheel is tested by `ci/smoke_test.py`.

To release a new version:
- update `version` in `pyproject.toml` and merge it in `master`
- tag it and push the tag (the tag must match the version, otherwise the release fails): `git tag v3.1.7 && git push origin v3.1.7`

## Building from sources

The build scripts below build the wheel for the Python version of your environment:
- the C++ dependencies (libqi, boost, openssl, ...) are built with Conan by `ci/conan_deps.sh` (the same script as the CI), in `./build/conan/`
- the default Conan profile is created if needed (`conan profile detect`)

💡 To build the wheels for all Python versions exactly like the CI, you can instead run cibuildwheel locally: `pipx install conan && pipx run cibuildwheel` (Linux builds run in a manylinux container and need Docker). The wheels are generated in `./wheelhouse/`.

<details>
<summary>Linux</summary>

💡 Built and tested by the CI on x86_64 (manylinux_2_28 container, GCC 14). Local builds were also tested on Ubuntu 22.04.

- install a C++ compiler
    - `sudo apt-get install build-essential`
- setup your python installation (you can use pyenv if you want to be able to choose a specific Python version)
    - `pyenv install 3.13`
    - `pyenv global 3.13`
- setup a python environment and switch to it (for example using venv)
    - `python -m venv ~/py-venv/py3.13-buildlibqipython`
    - `source ~/py-venv/py3.13-buildlibqipython/bin/activate`
- install needed python packages
    - `pip install -r requirements_linux.txt`
- clone this repository and go to the root of it
- execute the build script with all the needed steps
    - `chmod +x execute_build_wheel_linux.sh`
    - `./execute_build_wheel_linux.sh`

🥳 **Congratulations**
It should have generated the python wheel :
- in folder `./dist/fixed/`
- with name similar to `qi-3.1.7-cp313-cp313-manylinux_2_34_x86_64.whl`
- the platform tag depends on the glibc version of your machine (the CI builds in an older environment to support more distributions)
</details>

<details>
<summary>MacOS</summary>

💡 Built and tested by the CI on arm64 (MacOS 15, Xcode 16). Local builds were also tested on MacOS Sequoia (15.3.1).

- install a C++ compiler
    - `xcode-select --install`
- setup your python installation (you can use pyenv if you want to be able to choose a specific Python version)
    - `pyenv install 3.13`
    - `pyenv global 3.13`
- setup a python environment and switch to it (for example using venv)
    - `python -m venv ~/py-venv/py3.13-buildlibqipython`
    - `source ~/py-venv/py3.13-buildlibqipython/bin/activate`
- install needed python packages
    - `pip install -r requirements_macos.txt`
- clone this repository and go to the root of it
- execute the build script with all the needed steps
    - `chmod +x execute_build_wheel_macos.sh`
    - `./execute_build_wheel_macos.sh`

🥳 **Congratulations**
It should have generated the python wheel :
- in folder `./dist/fixed/`
- with name similar to `qi-3.1.7-cp313-cp313-macosx_11_0_arm64.whl`
- the wheel is compatible with MacOS 11+ (set `MACOSX_DEPLOYMENT_TARGET` to change it)
</details>

<details>
<summary>Windows</summary>

💡 Built and tested by the CI on x64 (Windows Server 2025, Visual Studio 2026). There is no dedicated build script on Windows: the wheel is built with cibuildwheel, like the CI.

- install a C++ compiler
    - [Visual Studio](https://visualstudio.microsoft.com/downloads/) or its Build Tools, with the "Desktop development with C++" workload
- install [Git for Windows](https://gitforwindows.org/) (its Git Bash runs `ci/conan_deps.sh`: make sure that `bash` in your `PATH` is Git Bash, not WSL)
- install [Python](https://www.python.org/downloads/windows/) and pipx
    - `python -m pip install --user pipx`
- install needed tools
    - `pipx install conan`
- clone this repository and go to the root of it
- build the wheel for one Python version (here 3.13)
    - `pipx run cibuildwheel --only cp313-win_amd64`

🥳 **Congratulations**
It should have generated the python wheel :
- in folder `./wheelhouse/`
- with name similar to `qi-3.1.7-cp313-cp313-win_amd64.whl`
</details>

## License

BSD-3-Clause, same as upstream. See [COPYING](COPYING).

Original code © Aldebaran Robotics / SoftBank Robotics Europe; modifications in this fork © 2025 Thibault Hervier.
