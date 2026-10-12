"""Repair a Windows wheel with delvewheel.

Usage: python ci/repair_wheel_windows.py WHEEL DEST_DIR

Bundles in the wheel the DLLs of the Conan dependencies (build/conan/bin), and
the MSVC C++ runtime (msvcp140.dll). The runtime is taken from the
redistributable of the latest Visual Studio (the one CMake uses to build the
wheel): a runtime older than the compiler may make the module crash, and the
one installed in the system is often older.
"""

import os
import shutil
import subprocess
import sys
from pathlib import Path

PROJECT_DIR = Path(__file__).resolve().parents[1]


def msvc_runtime_dir() -> Path:
    """Directory of the MSVC runtime DLLs redistributed with the latest Visual Studio."""
    vswhere = (Path(os.environ["ProgramFiles(x86)"])
               / "Microsoft Visual Studio" / "Installer" / "vswhere.exe")
    vs_dir = Path(subprocess.check_output(
        [str(vswhere), "-latest", "-products", "*",
         "-requires", "Microsoft.VisualStudio.Component.VC.Tools.x86.x64",
         "-property", "installationPath"],
        text=True).strip())
    version_file = vs_dir / "VC" / "Auxiliary" / "Build" / "Microsoft.VCRedistVersion.default.txt"
    version = version_file.read_text().strip()
    # e.g. VC/Redist/MSVC/14.51.36231/x64/Microsoft.VC145.CRT
    runtime_dirs = sorted((vs_dir / "VC" / "Redist" / "MSVC" / version / "x64").glob("Microsoft.VC*.CRT"))
    if not runtime_dirs:
        sys.exit(f"MSVC runtime redistributable not found in Visual Studio {vs_dir} ({version})")
    return runtime_dirs[-1]


def main() -> None:
    wheel, dest_dir = sys.argv[1:3]
    runtime_dir = msvc_runtime_dir()
    print(f"MSVC runtime: {runtime_dir}", flush=True)
    dll_dirs = [PROJECT_DIR / "build" / "conan" / "bin", runtime_dir]
    subprocess.run(
        [shutil.which("delvewheel") or "delvewheel", "repair",
         "--add-path", os.pathsep.join(str(d) for d in dll_dirs),
         "--include", "msvcp140.dll",
         "-w", dest_dir, wheel],
        check=True)


if __name__ == "__main__":
    main()
