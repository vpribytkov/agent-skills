"""Behavioral installer checks in disposable homes; no agent or network required.

python3 tests/test_installers.py
python tests/test_installers.py --powershell powershell
python tests/test_installers.py --powershell pwsh
"""
import argparse
import os
from pathlib import Path
import shutil
import subprocess
import sys
import tempfile
import unittest

parser = argparse.ArgumentParser()
parser.add_argument('--powershell', help='PowerShell executable; Windows only')
args, remaining = parser.parse_known_args()
REPO = Path(__file__).resolve().parents[1]


class InstallerTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory(prefix='agent install ')
        self.addCleanup(self.temp.cleanup)
        self.base = Path(self.temp.name)
        self.repo = self.base / 'checkout with spaces'
        self.repo.mkdir()
        for name in ('install.sh', 'install.ps1', 'AGENTS.md', 'workflows'):
            source = REPO / name
            dest = self.repo / name
            if source.is_dir():
                shutil.copytree(source, dest)
            else:
                shutil.copy2(source, dest)

        skill = self.repo / 'skills' / 'fixture-skill'
        skill.mkdir(parents=True)
        (skill / 'SKILL.md').write_text('fixture skill', encoding='utf-8')
        (skill / 'profile.example.yaml').write_text('key: default\n', encoding='utf-8')

        self.home = self.base / 'home'
        self.home.mkdir()
        self.codex = self.base / 'custom codex'
        self.codex.mkdir()
        self.skills = self.base / 'skill store'
        self.workflows = self.base / 'workflow store'
        self.env = {**os.environ, 'HOME': str(self.home), 'CODEX_HOME': str(self.codex)}
        self.agents_target = self.codex / 'AGENTS.md'

    def run_install(self, *, agents=True, codex=None, success=True, default_paths=False):
        if args.powershell:
            cmd = [args.powershell, '-NoProfile', '-ExecutionPolicy', 'Bypass',
                   '-File', str(self.repo / 'install.ps1'),
                   '-TargetRoot', str(self.skills)]
            if agents:
                cmd.append('-InstallAgents')
                if not default_paths:
                    cmd += ['-WorkflowsRoot', str(self.workflows)]
            if codex is not None:
                cmd += ['-CodexHome', str(codex)]
        else:
            cmd = ['sh', str(self.repo / 'install.sh')]
            if not default_paths:
                cmd.append(str(self.skills))
            if agents:
                cmd.append('--agents')
                if not default_paths:
                    cmd += ['--workflows-root', str(self.workflows)]
            if codex is not None:
                cmd += ['--codex-home', str(codex)]

        env = self.env.copy()
        if args.powershell:
            env = {key: value for key, value in env.items()
                   if key.casefold() != 'psmodulepath'}
        result = subprocess.run(cmd, env=env, text=True, capture_output=True)
        if success:
            self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
        else:
            self.assertNotEqual(result.returncode, 0, result.stdout + result.stderr)
        return result

    def test_default_installs_skills_only(self):
        self.run_install(agents=False)
        installed = self.skills / 'fixture-skill'
        self.assertEqual((installed / 'SKILL.md').read_text(), 'fixture skill')
        self.assertFalse(self.agents_target.exists())
        self.assertFalse(self.workflows.exists())

    def test_global_install_links_agents_and_workflows(self):
        self.run_install()
        self.assertTrue(self.agents_target.is_symlink())
        self.assertEqual(self.agents_target.resolve(), (self.repo / 'AGENTS.md').resolve())
        self.assertTrue(self.workflows.is_symlink() or self.workflows.is_dir())
        self.assertEqual(self.workflows.resolve(), (self.repo / 'workflows').resolve())

    def test_existing_global_target_is_an_error_and_is_preserved(self):
        self.agents_target.write_text('local rules', encoding='utf-8')
        self.run_install(success=False)
        self.assertEqual(self.agents_target.read_text(), 'local rules')
        self.assertFalse(self.workflows.exists())

    def test_existing_workflows_target_is_an_error_and_is_preserved(self):
        self.workflows.mkdir()
        keep = self.workflows / 'keep'
        keep.write_text('local workflow', encoding='utf-8')
        self.run_install(success=False)
        self.assertEqual(keep.read_text(), 'local workflow')
        self.assertFalse(self.agents_target.exists())

    def test_rerun_global_install_errors_without_changing_links(self):
        self.run_install()
        agents_link = os.readlink(self.agents_target)
        workflows_target = self.workflows.resolve()
        self.run_install(success=False)
        self.assertEqual(os.readlink(self.agents_target), agents_link)
        self.assertEqual(self.workflows.resolve(), workflows_target)

    def test_skill_collision_blocks_global_install(self):
        collision = self.skills / 'fixture-skill'
        collision.mkdir(parents=True)
        (collision / 'keep').write_text('keep', encoding='utf-8')
        self.run_install(success=False)
        self.assertFalse(self.agents_target.exists())
        self.assertFalse(self.workflows.exists())

    def test_explicit_codex_home(self):
        alternate = self.base / 'alternate codex'
        self.run_install(codex=alternate)
        target = alternate / 'AGENTS.md'
        self.assertTrue(target.is_symlink())
        self.assertEqual(target.resolve(), (self.repo / 'AGENTS.md').resolve())

    @unittest.skipIf(args.powershell, 'POSIX HOME fallback; Windows uses native $HOME')
    def test_default_paths_without_codex_home(self):
        self.env.pop('CODEX_HOME')
        self.run_install(default_paths=True)
        agents = self.home / '.codex' / 'AGENTS.md'
        workflows = self.home / '.agents' / 'workflows'
        self.assertTrue(agents.is_symlink())
        self.assertEqual(agents.resolve(), (self.repo / 'AGENTS.md').resolve())
        self.assertTrue(workflows.is_symlink())
        self.assertEqual(workflows.resolve(), (self.repo / 'workflows').resolve())


if __name__ == '__main__':
    unittest.main(argv=[sys.argv[0], *remaining], verbosity=2)
