#!/usr/bin/env python3
"""Tests for update_skills.py"""

import os
import sys
import tempfile
import unittest
from pathlib import Path
from unittest.mock import patch

# Add scripts directory to path for import
sys.path.insert(0, str(Path(__file__).parent.parent.parent / "scripts"))
import update_skills


class TestDiffFiles(unittest.TestCase):
    def test_identical_files_return_none(self):
        with tempfile.TemporaryDirectory() as tmpdir:
            file1 = Path(tmpdir) / "file1.txt"
            file2 = Path(tmpdir) / "file2.txt"
            file1.write_text("same content")
            file2.write_text("same content")

            result = update_skills.diff_files(file1, file2)
            self.assertIsNone(result)

    def test_different_files_return_diff(self):
        with tempfile.TemporaryDirectory() as tmpdir:
            file1 = Path(tmpdir) / "file1.txt"
            file2 = Path(tmpdir) / "file2.txt"
            file1.write_text("old content")
            file2.write_text("new content")

            result = update_skills.diff_files(file1, file2)
            self.assertIsNotNone(result)
            self.assertIn("old content", result)
            self.assertIn("new content", result)


class TestMain(unittest.TestCase):
    def test_no_source_directory(self):
        with tempfile.TemporaryDirectory() as tmpdir:
            with patch.dict(os.environ, {
                "SKILLS_SRC": f"{tmpdir}/nonexistent",
                "SKILLS_DEST": f"{tmpdir}/dest",
            }):
                # Should not raise, just print message
                update_skills.main()

    def test_no_claude_directory(self):
        with tempfile.TemporaryDirectory() as tmpdir:
            src = Path(tmpdir) / "src"
            src.mkdir()
            dest = Path(tmpdir) / "project" / ".claude" / "skills" / "nix-shared"

            with patch.dict(os.environ, {
                "SKILLS_SRC": str(src),
                "SKILLS_DEST": str(dest),
            }):
                # Should not raise, just print message
                update_skills.main()

    def test_copies_new_skills(self):
        with tempfile.TemporaryDirectory() as tmpdir:
            # Setup source
            src = Path(tmpdir) / "src"
            (src / "commit").mkdir(parents=True)
            (src / "commit" / "SKILL.md").write_text("commit skill content")

            # Setup dest (with .claude parent)
            project = Path(tmpdir) / "project"
            claude_dir = project / ".claude"
            claude_dir.mkdir(parents=True)
            dest = claude_dir / "skills" / "nix-shared"

            with patch.dict(os.environ, {
                "SKILLS_SRC": str(src),
                "SKILLS_DEST": str(dest),
            }):
                update_skills.main()

            # Verify skill was copied
            copied = dest / "commit" / "SKILL.md"
            self.assertTrue(copied.exists())
            self.assertEqual(copied.read_text(), "commit skill content")

    def test_does_not_overwrite_without_confirmation(self):
        with tempfile.TemporaryDirectory() as tmpdir:
            # Setup source
            src = Path(tmpdir) / "src"
            (src / "commit").mkdir(parents=True)
            (src / "commit" / "SKILL.md").write_text("new content")

            # Setup dest with existing file
            project = Path(tmpdir) / "project"
            claude_dir = project / ".claude"
            claude_dir.mkdir(parents=True)
            dest = claude_dir / "skills" / "nix-shared"
            (dest / "commit").mkdir(parents=True)
            (dest / "commit" / "SKILL.md").write_text("old content")

            with patch.dict(os.environ, {
                "SKILLS_SRC": str(src),
                "SKILLS_DEST": str(dest),
            }):
                # Mock confirm to return False
                with patch.object(update_skills, "confirm", return_value=False):
                    update_skills.main()

            # Verify original content preserved
            self.assertEqual(
                (dest / "commit" / "SKILL.md").read_text(),
                "old content"
            )

    def test_overwrites_with_confirmation(self):
        with tempfile.TemporaryDirectory() as tmpdir:
            # Setup source
            src = Path(tmpdir) / "src"
            (src / "commit").mkdir(parents=True)
            (src / "commit" / "SKILL.md").write_text("new content")

            # Setup dest with existing file
            project = Path(tmpdir) / "project"
            claude_dir = project / ".claude"
            claude_dir.mkdir(parents=True)
            dest = claude_dir / "skills" / "nix-shared"
            (dest / "commit").mkdir(parents=True)
            (dest / "commit" / "SKILL.md").write_text("old content")

            with patch.dict(os.environ, {
                "SKILLS_SRC": str(src),
                "SKILLS_DEST": str(dest),
            }):
                # Mock confirm to return True
                with patch.object(update_skills, "confirm", return_value=True):
                    update_skills.main()

            # Verify content was updated
            self.assertEqual(
                (dest / "commit" / "SKILL.md").read_text(),
                "new content"
            )


if __name__ == "__main__":
    unittest.main()
