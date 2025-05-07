# qi package - Python binding for Libqi

This repository contains the Python bindings of [LibQi](https://github.com/funwithagents/libqi), the library used to communicate with robots using Naoqi (Nao & Pepper).

These LibQi python bindings correspond to the  `qi` Python module.

## Up-to-date repository for compatibility with recent Python versions and OS

- This repository is a fork of the official libqi-python repository (that seems to be not maintained by Aldebaran anymore).
- I created it mainly to update the code of the package to be able to build it with recent versions of Python (3.10+) on MacOS and Linux

## Pre-built packages

- Check the [Releases](https://github.com/funwithagents/libqi-python/releases) to directly retrieve python wheels compatible with recent version of Python, for MacOS and Linux
- To install the packages
    - download the wheel file (.whl) corresponding to your python version and OS
    - install the package using `pip install path/to/wheel.whl`

## Building from sources

<details>
<summary>MacOS</summary>

>[!NOTE]
>💡 This has been tested on a Mac with arm64 architecture & MacOS Sequoia (15.3.1)

- setup you python installation (you can use pyenv if you want to be able to choose a specific Python version)
    - `pyenv install 3.13`
    - `pyenv global 3.13`
- setup a python environment and switch to it (for example using venv)
    - `python -m venv ~/py-venv/py3.13-buildlibqipython`
    - `source ~/py-venv/py3.13-buildlibqipython/bin/activate`
- install needed python packages
    - `pip install -r requirements_macos.txt`
- clone this repository and go to the root of it
- generate (if not already done) your conan profile
    - `conan profile detect`
- check you conan profile
    - `cat ~/.conan2/profiles/default`
    - it should display something similar to this
        
        ```
        [settings]
        arch=armv8
        build_type=Release
        compiler=apple-clang
        compiler.cppstd=gnu17
        compiler.libcxx=libc++
        compiler.version=16
        os=Macos
        ```
        
- execute the build script with all the needed steps
    - `chmod +x build_wheel_macos.sh`
    - `./build_wheel_macos.sh`

🥳 **Congratulations**
It should have generated the python wheel : 
- in folder `./dist/fixed/`
- with name similar to `qi-3.1.6-cp313-cp313-macosx_15_0_arm64.whl`
</details>

<details>
<summary>Linux</summary>

>[!NOTE]
>💡 This has been tested on a x86_64 architecture & Ubuntu 22.04

- install c++ compiler
    - `sudo apt-get install build-essential`
- setup you python installation (you can use pyenv if you want to be able to choose a specific Python version)
    - `pyenv install 3.13`
    - `pyenv global 3.13`
- setup a python environment and switch to it (for example using venv)
    - `python -m venv ~/py-venv/py3.13-buildlibqipython`
    - `source ~/py-venv/py3.13-buildlibqipython/bin/activate`
- install needed python packages
    - `pip install -r requirements_linux.txt`
- clone this repository and go to the root of it
- generate (if not already done) your conan profile
    - `conan profile detect`
- check you conan profile
    - `cat $HOME/.conan2/profiles/default`
    - it should display something similar to this
        
        ```
        [settings]
        arch=x86_64
        build_type=Release
        compiler=gcc
        compiler.cppstd=gnu17
        compiler.libcxx=libstdc++11
        compiler.version=11
        os=Linux
        ```
        
- execute the build script with all the needed steps
    - `chmod +x build_wheel_linux.sh`
    - `./build_wheel_linux.sh`

🥳 **Congratulations**
It should have generated the python wheel : 
- in folder `./dist/fixed/`
- with name similar to `qi-3.1.6-cp313-cp313-manylinux_2_34_x86_64.whl`
</details>
