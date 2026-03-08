#!/usr/bin/env python3
from __future__ import annotations

import argparse
import os
import re
import subprocess
import sys
import tempfile
from pathlib import Path

REPO_ROOT = Path(__file__).resolve().parent.parent
SHARED_PATH = REPO_ROOT / ".Brewfile.shared"
DARWIN_PATH = REPO_ROOT / ".Brewfile.darwin"
LINUX_PATH = REPO_ROOT / ".Brewfile.linux"
COMBINED_PATH = REPO_ROOT / ".Brewfile"
LINE_RE = re.compile(r'^(tap|brew|cask)\s+"([^"]+)"(?:,.*)?$')
TYPE_ORDER = {"tap": 0, "brew": 1, "cask": 2}
DARWIN_ONLY_FORMULAE = {"container", "mint", "xcodegen"}


def parse_brewfile(path: Path) -> dict[tuple[str, str], str]:
    entries: dict[tuple[str, str], str] = {}
    if not path.exists():
        return entries

    for raw in path.read_text().splitlines():
        line = raw.strip()
        match = LINE_RE.match(line)
        if match:
            entries[(match.group(1), match.group(2))] = line
    return entries


def sorted_lines(entries: dict[tuple[str, str], str]) -> list[str]:
    keys = sorted(entries, key=lambda item: (TYPE_ORDER.get(item[0], 99), item[1]))
    return [entries[key] for key in keys]


def write_component(path: Path, description: str, entries: dict[tuple[str, str], str]) -> None:
    body = [
        "# Managed by scripts/brewfile-manager.py.",
        f"# {description}",
        "",
        *sorted_lines(entries),
        "",
    ]
    path.write_text("\n".join(body))


def render_combined() -> None:
    shared = parse_brewfile(SHARED_PATH)
    darwin = parse_brewfile(DARWIN_PATH)
    linux = parse_brewfile(LINUX_PATH)

    body = [
        "# Managed by scripts/brewfile-manager.py.",
        "# Formulae and taps are shared by default. Darwin-only apps and overrides live in .Brewfile.darwin.",
        "",
        "# Shared packages",
        *sorted_lines(shared),
        "",
        "# Darwin-only packages",
        *sorted_lines(darwin),
        "",
        "# Linux-only packages",
        *sorted_lines(linux),
        "",
    ]
    COMBINED_PATH.write_text("\n".join(body))


def dump_current_state(os_name: str) -> dict[tuple[str, str], str]:
    fd, temp_path = tempfile.mkstemp(prefix="brewfile-dump-", suffix=".Brewfile")
    os.close(fd)

    try:
        cmd = [
            "brew",
            "bundle",
            "dump",
            "--force",
            f"--file={temp_path}",
            "--no-vscode",
            "--no-go",
            "--no-cargo",
            "--no-uv",
        ]
        if os_name == "Linux":
            cmd.append("--no-flatpak")

        env = os.environ.copy()
        env["BREWFILE_SYNC_DISABLE"] = "1"
        subprocess.run(cmd, check=True, env=env)

        dumped = parse_brewfile(Path(temp_path))
        if os_name == "Linux":
            dumped = {key: line for key, line in dumped.items() if key[0] != "cask"}
        return dumped
    finally:
        Path(temp_path).unlink(missing_ok=True)


def classify_target(os_name: str, key: tuple[str, str]) -> str:
    kind, name = key
    if kind == "cask":
        return "darwin" if os_name == "Darwin" else "linux"
    if os_name == "Darwin" and kind == "brew" and name in DARWIN_ONLY_FORMULAE:
        return "darwin"
    return "shared"


def candidate_names(name: str) -> list[str]:
    candidates = [name]
    if "/" in name:
        candidates.append(name.rsplit("/", 1)[-1])
    return candidates


def detect_installed_entry(current_state: dict[tuple[str, str], str], name: str, explicit_kind: str | None) -> tuple[tuple[str, str], str] | None:
    names = candidate_names(name)
    kinds = [explicit_kind] if explicit_kind else ["brew", "cask"]
    for candidate in names:
        for kind in kinds:
            if kind is None:
                continue
            key = (kind, candidate)
            if key in current_state:
                return key, current_state[key]
    return None


def remove_named_entries(entries: dict[tuple[str, str], str], name: str, explicit_kind: str | None) -> None:
    names = set(candidate_names(name))
    for key in list(entries):
        kind, entry_name = key
        if entry_name not in names:
            continue
        if explicit_kind and kind != explicit_kind:
            continue
        del entries[key]


def update_tracking(brew_args: list[str]) -> int:
    if not brew_args:
        return 0

    command = brew_args[0]
    flags = {arg for arg in brew_args[1:] if arg.startswith("-")}
    names = [arg for arg in brew_args[1:] if not arg.startswith("-")]
    if not names:
        return 0

    os_name = subprocess.check_output(["uname", "-s"], text=True).strip()
    if os_name not in {"Darwin", "Linux"}:
        return 0

    shared = parse_brewfile(SHARED_PATH)
    darwin = parse_brewfile(DARWIN_PATH)
    linux = parse_brewfile(LINUX_PATH)

    explicit_kind = None
    if "--cask" in flags:
        explicit_kind = "cask"
    elif "--formula" in flags:
        explicit_kind = "brew"
    elif command in {"tap", "untap"}:
        explicit_kind = "tap"

    if command in {"install", "reinstall"}:
        current_state = dump_current_state(os_name)
        for name in names:
            detected = detect_installed_entry(current_state, name, explicit_kind)
            if detected is None:
                continue
            key, line = detected
            if key in shared:
                shared[key] = line
                continue
            if key in darwin:
                darwin[key] = line
                continue
            if key in linux:
                linux[key] = line
                continue

            target = classify_target(os_name, key)
            if target == "shared":
                shared[key] = line
            elif target == "darwin":
                darwin[key] = line
            else:
                linux[key] = line
    elif command in {"uninstall", "remove", "untap"}:
        for name in names:
            remove_named_entries(shared, name, explicit_kind)
            remove_named_entries(darwin, name, explicit_kind)
            remove_named_entries(linux, name, explicit_kind)
    elif command == "tap":
        for name in names:
            key = ("tap", name)
            shared[key] = f'tap "{name}"'
    else:
        return 0

    write_component(SHARED_PATH, "Shared formulae and taps applied on both macOS and Linux.", shared)
    write_component(DARWIN_PATH, "Darwin-only packages, including casks and formula overrides.", darwin)
    write_component(LINUX_PATH, "Linux-only package overrides.", linux)
    render_combined()
    return 0


def main() -> int:
    parser = argparse.ArgumentParser(description="Manage split Brewfiles for dotfiles.")
    subparsers = parser.add_subparsers(dest="command", required=True)
    subparsers.add_parser("render", help="Regenerate the combined .Brewfile from component files.")
    track_parser = subparsers.add_parser("track", help="Update Brewfiles after a brew command succeeds.")
    track_parser.add_argument("brew_args", nargs=argparse.REMAINDER)
    args = parser.parse_args()

    if args.command == "render":
        render_combined()
        return 0
    if args.command == "track":
        brew_args = args.brew_args
        if brew_args and brew_args[0] == "--":
            brew_args = brew_args[1:]
        return update_tracking(brew_args)
    return 1


if __name__ == "__main__":
    raise SystemExit(main())
