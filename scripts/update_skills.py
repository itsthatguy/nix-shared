#!/usr/bin/env python3
"""Update Claude skills from nix-shared upstream."""

import os
import sys
import subprocess
from pathlib import Path


def diff_files(local: Path, upstream: Path) -> str | None:
    """Return colored diff if files differ, None if same."""
    result = subprocess.run(
        ["diff", "-u", str(local), str(upstream)],
        capture_output=True,
        text=True,
    )
    if result.returncode == 0:
        return None
    # Strip the header lines, add color
    result = subprocess.run(
        ["diff", "--color=always", "-u", str(local), str(upstream)],
        capture_output=True,
        text=True,
    )
    lines = result.stdout.split("\n")[2:]  # skip --- and +++ lines
    return "\n".join(lines)


def confirm(prompt: str) -> bool:
    """Prompt user for yes/no confirmation."""
    while True:
        response = input(f"{prompt} [y/n] ").strip().lower()
        if response in ("y", "yes"):
            return True
        if response in ("n", "no"):
            return False


def main():
    skills_src = Path(os.environ.get("SKILLS_SRC", ""))
    skills_dest = Path(os.environ.get("SKILLS_DEST", ""))

    if not skills_src.is_dir():
        print("No upstream skills found")
        return

    claude_dir = skills_dest.parent.parent  # .claude/skills/nix-shared -> .claude
    if not claude_dir.is_dir():
        print("No .claude directory in project")
        return

    updated = 0
    skipped = 0

    for skill_file in sorted(skills_src.glob("*/SKILL.md")):
        skill = skill_file.parent.name
        dest_file = skills_dest / skill / "SKILL.md"

        if not dest_file.exists():
            dest_file.parent.mkdir(parents=True, exist_ok=True)
            dest_file.write_text(skill_file.read_text())
            print(f"✓ Added: {skill}")
            updated += 1
        else:
            diff = diff_files(dest_file, skill_file)
            if diff:
                print(f"\n═══ {skill} has changes ═══")
                print(diff)
                print()
                if confirm(f"Update {skill}?"):
                    dest_file.write_text(skill_file.read_text())
                    print(f"✓ Updated: {skill}")
                    updated += 1
                else:
                    print(f"⊘ Skipped: {skill}")
                    skipped += 1

    print()
    if updated == 0 and skipped == 0:
        print("All skills up to date")
    else:
        print(f"Updated: {updated}, Skipped: {skipped}")


if __name__ == "__main__":
    main()
