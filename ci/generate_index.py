"""Generate a PEP 503 package index of the wheels attached to the GitHub Releases.

Usage: python ci/generate_index.py OUTPUT_DIR

Writes OUTPUT_DIR/simple/index.html and OUTPUT_DIR/simple/qi/index.html, to be
deployed to GitHub Pages. The index only contains links: the wheels stay in the
GitHub Releases. Drafts and pre-releases are left out (a pre-release "v3.1.7-rc1"
contains wheels with the same file names as the release "v3.1.7").

The repository is read from GITHUB_REPOSITORY, and GITHUB_TOKEN (optional) is
used to call the GitHub API.
"""

from __future__ import annotations

import hashlib
import html
import json
import os
import re
import sys
import urllib.request
from pathlib import Path

PROJECT = "qi"
API_URL = "https://api.github.com"


def api_get(path: str) -> list:
    request = urllib.request.Request(f"{API_URL}{path}", headers={"Accept": "application/vnd.github+json"})
    if token := os.environ.get("GITHUB_TOKEN"):
        request.add_header("Authorization", f"Bearer {token}")
    with urllib.request.urlopen(request) as response:
        return json.load(response)


def releases(repository: str) -> list:
    """Published releases, oldest first."""
    result = []
    page = 1
    while batch := api_get(f"/repos/{repository}/releases?per_page=100&page={page}"):
        result += batch
        page += 1
    published = [r for r in result if not r["draft"] and not r["prerelease"]]
    return sorted(published, key=lambda r: r["published_at"])


def sha256(asset: dict) -> str:
    """SHA-256 of an asset: given by GitHub, or computed for assets uploaded before mid-2025."""
    if digest := asset.get("digest"):
        algorithm, _, value = digest.partition(":")
        if algorithm == "sha256":
            return value
    print(f"Computing the SHA-256 of {asset['name']}", flush=True)
    hasher = hashlib.sha256()
    with urllib.request.urlopen(asset["browser_download_url"]) as response:
        while chunk := response.read(1 << 20):
            hasher.update(chunk)
    return hasher.hexdigest()


def requires_python(wheel_name: str) -> str | None:
    """Python version of a CPython wheel, from its tag (e.g. "cp313" -> "==3.13.*")."""
    python_tag = wheel_name.removesuffix(".whl").split("-")[-3]
    if match := re.fullmatch(r"cp(\d)(\d+)", python_tag):
        return f"=={match[1]}.{match[2]}.*"
    return None


def page(title: str, links: list[str]) -> str:
    body = "\n".join(f"    {link}<br>" for link in links)
    return (f"<!DOCTYPE html>\n<html>\n  <head>\n    <meta name=\"pypi:repository-version\" content=\"1.0\">\n"
            f"    <title>{html.escape(title)}</title>\n  </head>\n  <body>\n"
            f"    <h1>{html.escape(title)}</h1>\n{body}\n  </body>\n</html>\n")


def main() -> None:
    output_dir = Path(sys.argv[1])
    repository = os.environ["GITHUB_REPOSITORY"]

    links = []
    seen = set()
    for release in releases(repository):
        for asset in sorted(release["assets"], key=lambda a: a["name"]):
            name = asset["name"]
            if not name.endswith(".whl"):
                continue
            if name in seen:
                sys.exit(f"{name} is attached to several releases")
            seen.add(name)
            url = f"{asset['browser_download_url']}#sha256={sha256(asset)}"
            attributes = f'href="{html.escape(url)}"'
            if python := requires_python(name):
                attributes += f' data-requires-python="{html.escape(python)}"'
            links.append(f"<a {attributes}>{html.escape(name)}</a>")
        print(f"{release['tag_name']}: {len(release['assets'])} assets", flush=True)

    project_dir = output_dir / "simple" / PROJECT
    project_dir.mkdir(parents=True, exist_ok=True)
    (output_dir / "simple" / "index.html").write_text(
        page("Simple index", [f'<a href="{PROJECT}/">{PROJECT}</a>']))
    (project_dir / "index.html").write_text(page(f"Links for {PROJECT}", links))
    print(f"{len(links)} wheels in {project_dir / 'index.html'}")


if __name__ == "__main__":
    main()
