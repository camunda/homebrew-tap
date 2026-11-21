#!/usr/bin/env python3
"""Bump the tap's formulas to the latest upstream releases.

    .github/scripts/update.py [d8ctl] [c8ctl]     (default: both)

d8ctl: the newest non-draft GitHub release of camunda/d8ctl (pre-releases
included; d8ctl flags every 0.x release as one). Checksums come from the
release's own .sha256 sidecars, which are checked against the downloaded
binary.
c8ctl: the `latest` dist-tag of @camunda8/cli on npm; sha256 of its tarball.

Rewrites Formula/<name>.rb in place and prints `<name> <old> -> <new>` for
each change. Exit 0 whether or not anything changed. Python stdlib only.
"""
import hashlib
import json
import os
import re
import sys
import urllib.request

ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
D8CTL_ASSETS = ["d8ctl-darwin-arm64", "d8ctl-darwin-amd64", "d8ctl-linux-arm64", "d8ctl-linux-amd64"]


def get(url, accept=None):
    req = urllib.request.Request(url, headers={"User-Agent": "camunda-homebrew-tap"})
    if accept:
        req.add_header("Accept", accept)
    token = os.environ.get("GITHUB_TOKEN")
    if token and url.startswith("https://api.github.com/"):
        req.add_header("Authorization", f"Bearer {token}")
    with urllib.request.urlopen(req, timeout=60) as r:
        return r.read()


def formula(name):
    path = os.path.join(ROOT, "Formula", f"{name}.rb")
    with open(path, encoding="utf-8") as f:
        return path, f.read()


def save(path, text):
    with open(path, "w", encoding="utf-8") as f:
        f.write(text)


def sha256(data):
    return hashlib.sha256(data).hexdigest()


def update_d8ctl():
    path, text = formula("d8ctl")
    old = re.search(r'^  version "([^"]+)"', text, re.M).group(1)
    releases = json.loads(get("https://api.github.com/repos/camunda/d8ctl/releases?per_page=20",
                              "application/vnd.github+json"))
    release = next(r for r in releases if not r["draft"])
    new = release["tag_name"].lstrip("v")
    if new == old:
        return
    # API asset URLs work for public and (with GITHUB_TOKEN) private repos alike.
    assets = {a["name"]: a["url"] for a in release["assets"]}
    octet = "application/octet-stream"
    for asset in D8CTL_ASSETS:
        if asset not in assets or f"{asset}.sha256" not in assets:
            sys.exit(f"d8ctl v{new}: release is missing {asset} or its .sha256")
        want = get(assets[f"{asset}.sha256"], octet).decode().split()[0]
        got = sha256(get(assets[asset], octet))
        if want != got:
            sys.exit(f"d8ctl v{new}: {asset} sha256 {got} != sidecar {want}")
        # The url line for this asset, then the sha256 line that follows it.
        text, n = re.subn(
            r'(url "https://github\.com/camunda/d8ctl/releases/download/)v[^/]+(/' + re.escape(asset) + r'"\n\s+sha256 ")[0-9a-f]{64}"',
            lambda m: f'{m.group(1)}v{new}{m.group(2)}{want}"',
            text,
        )
        if n != 1:
            sys.exit(f"Formula/d8ctl.rb: expected one url+sha256 pair for {asset}, found {n}")
    text = re.sub(r'^  version "[^"]+"', f'  version "{new}"', text, count=1, flags=re.M)
    save(path, text)
    print(f"d8ctl {old} -> {new}")


def update_c8ctl():
    path, text = formula("c8ctl")
    m = re.search(r'^  url "https://registry\.npmjs\.org/@camunda8/cli/-/cli-([^"]+)\.tgz"', text, re.M)
    old = m.group(1)
    latest = json.loads(get("https://registry.npmjs.org/@camunda8/cli/latest"))
    new = latest["version"]
    if new == old:
        return
    tarball = latest["dist"]["tarball"]
    digest = sha256(get(tarball))
    text = re.sub(r'^  url "[^"]+"', f'  url "{tarball}"', text, count=1, flags=re.M)
    text = re.sub(r'^  sha256 "[0-9a-f]{64}"', f'  sha256 "{digest}"', text, count=1, flags=re.M)
    save(path, text)
    print(f"c8ctl {old} -> {new}")


if __name__ == "__main__":
    names = sys.argv[1:] or ["d8ctl", "c8ctl"]
    for name in names:
        {"d8ctl": update_d8ctl, "c8ctl": update_c8ctl}[name]()
