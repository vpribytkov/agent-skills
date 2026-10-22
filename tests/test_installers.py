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
        self.source = self.repo / 'AGENTS.md'
        self.workflow_sources = {name: self.repo / 'workflows' / name for name in (
            'planning.md', 'investigation-rca.md', 'integration-tests.md',
            'observability.md', 'openspec.md')}
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
        self.target = self.codex / 'AGENTS.md'
        self.workflow_targets = {name: self.workflows / name for name in self.workflow_sources}

    def run_install(self, *, agents=True, copy=False, replace=False,
                    codex=None, success=True, default_skills=False):
        if args.powershell:
            cmd = [args.powershell, '-NoProfile', '-ExecutionPolicy', 'Bypass',
                   '-File', str(self.repo / 'install.ps1')]
            # Windows PowerShell's $HOME does not follow the process HOME variable.
            cmd += ['-TargetRoot', str(self.skills)]
            if agents:
                cmd.append('-InstallAgents')
                if not default_skills:
                    cmd += ['-WorkflowsRoot', str(self.workflows)]
            if copy:
                cmd += ['-AgentsMode', 'Copy']
            if replace:
                cmd.append('-ReplaceAgents')
            if codex is not None:
                cmd += ['-CodexHome', str(codex)]
        else:
            cmd = ['sh', str(self.repo / 'install.sh')]
            if not default_skills:
                cmd.append(str(self.skills))
            if agents:
                cmd.append('--agents')
                if not default_skills:
                    cmd += ['--workflows-root', str(self.workflows)]
            if copy:
                cmd.append('--copy')
            if replace:
                cmd.append('--replace-agents')
            if codex is not None:
                cmd += ['--codex-home', str(codex)]
        env = self.env.copy()
        if args.powershell:
            # A pwsh -> Python -> powershell chain otherwise inherits PS7 modules
            # into Windows PowerShell and breaks built-in module autoloading.
            env = {key: value for key, value in env.items()
                   if key.casefold() != 'psmodulepath'}
        result = subprocess.run(cmd, env=env, text=True, capture_output=True)
        if success:
            self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
        else:
            self.assertNotEqual(result.returncode, 0, result.stdout + result.stderr)
        return result

    def backups(self):
        return list(self.codex.glob('AGENTS.md.backup.*'))

    def assert_no_staging(self):
        self.assertEqual(list(self.codex.rglob('.agents-install*')), [])

    def test_default_installs_skills_only_and_preserves_local_profile(self):
        self.target.write_text('local rules', encoding='utf-8')
        self.run_install(agents=False)
        self.assertEqual(self.target.read_text(), 'local rules')
        self.assertFalse(self.workflows.exists())
        installed = self.skills / 'fixture-skill'
        self.assertEqual((installed / 'SKILL.md').read_text(), 'fixture skill')
        (installed / 'profile.yaml').write_text('key: local\n', encoding='utf-8')
        self.run_install(agents=False)
        self.assertEqual((installed / 'profile.yaml').read_text(), 'key: local\n')

    def test_link_is_idempotent_and_tracks_source_replacement(self):
        self.run_install()
        self.assertTrue(self.target.is_symlink())
        self.assertEqual(self.target.resolve(), self.source.resolve())
        self.run_install()
        new_source = self.source.with_suffix('.new')
        new_source.write_text('updated after checkout\n', encoding='utf-8')
        os.replace(new_source, self.source)
        self.assertEqual(self.target.read_text(), 'updated after checkout\n')
        self.assertEqual(self.backups(), [])
        self.assert_no_staging()

    def test_copy_is_idempotent_and_explicit_update_backs_up_old_bytes(self):
        self.run_install(copy=True)
        original = self.source.read_bytes()
        self.assertFalse(self.target.is_symlink())
        self.assertEqual(self.target.read_bytes(), original)
        self.run_install(copy=True)
        self.assertEqual(self.backups(), [])
        self.source.write_text('new rules\n', encoding='utf-8')
        self.run_install(copy=True, success=False)
        self.assertEqual(self.target.read_bytes(), original)
        self.run_install(copy=True, replace=True)
        self.assertEqual(self.target.read_bytes(), self.source.read_bytes())
        self.assertEqual([p.read_bytes() for p in self.backups()], [original])
        self.assert_no_staging()

    def test_existing_file_requires_explicit_replacement(self):
        original = b'local rules\r\n'
        self.target.write_bytes(original)
        self.run_install(success=False)
        self.assertEqual(self.target.read_bytes(), original)
        self.run_install(replace=True)
        self.assertTrue(self.target.is_symlink())
        self.assertEqual([p.read_bytes() for p in self.backups()], [original])

    def test_nonempty_empty_and_dangling_override_are_never_touched(self):
        override = self.codex / 'AGENTS.override.md'
        for content in (b'private override', b''):
            with self.subTest(content=content):
                override.write_bytes(content)
                self.run_install(copy=True, replace=True, success=False)
                self.assertEqual(override.read_bytes(), content)
                self.assertFalse(self.target.exists())
                override.unlink()
        override.symlink_to(self.base / 'missing override')
        self.run_install(copy=True, replace=True, success=False)
        self.assertTrue(override.is_symlink())
        self.assertFalse(self.target.exists())

    def test_foreign_and_dangling_links_are_never_replaced(self):
        foreign = self.base / 'foreign.md'
        foreign.write_text('foreign rules', encoding='utf-8')
        for source in (foreign, self.base / 'missing.md'):
            with self.subTest(source=source):
                self.target.symlink_to(source)
                original_target = os.readlink(self.target)
                try:
                    self.run_install(copy=True, replace=True, success=False)
                    self.assertTrue(self.target.is_symlink())
                    # Windows may expose a \\?\ prefix; assert preservation,
                    # not the platform's textual spelling of the target path.
                    self.assertEqual(os.readlink(self.target), original_target)
                finally:
                    self.target.unlink(missing_ok=True)
        self.assertEqual(foreign.read_text(), 'foreign rules')
        self.assertEqual(self.backups(), [])

    def test_directory_and_source_as_target_are_rejected(self):
        self.target.mkdir()
        keep = self.target / 'keep'
        keep.write_text('keep', encoding='utf-8')
        self.run_install(copy=True, replace=True, success=False)
        self.assertEqual(keep.read_text(), 'keep')
        before = self.source.read_bytes()
        self.run_install(codex=self.source.parent, replace=True, success=False)
        self.assertEqual(self.source.read_bytes(), before)

    def test_explicit_codex_home_overrides_environment(self):
        alternate = self.base / 'alternate home'
        self.run_install(copy=True, codex=alternate)
        self.assertEqual((alternate / 'AGENTS.md').read_bytes(), self.source.read_bytes())
        for name, source in self.workflow_sources.items():
            self.assertEqual(self.workflow_targets[name].read_bytes(), source.read_bytes())
            self.assertFalse(self.workflow_targets[name].is_symlink())
        self.assertFalse(self.target.exists())

    def test_global_options_require_opt_in(self):
        self.run_install(agents=False, copy=True, success=False)
        self.assertFalse(self.target.exists())
        self.assertFalse(self.skills.exists())

    def test_skill_collision_does_not_install_global_instructions(self):
        collision = self.skills / 'fixture-skill'
        collision.mkdir(parents=True)
        (collision / 'local').write_text('keep', encoding='utf-8')
        self.run_install(copy=True, success=False)
        self.assertEqual((collision / 'local').read_text(), 'keep')
        self.assertFalse(self.target.exists())

    def test_workflows_are_copied_and_updates_require_explicit_replace(self):
        self.run_install()
        for name, source in self.workflow_sources.items():
            target = self.workflow_targets[name]
            self.assertEqual(target.read_bytes(), source.read_bytes())
            self.assertFalse(target.is_symlink())

        name = 'planning.md'
        original = self.workflow_targets[name].read_bytes()
        self.workflow_sources[name].write_bytes(b'updated planning\n')
        self.run_install(success=False)
        self.assertEqual(self.workflow_targets[name].read_bytes(), original)
        self.run_install(replace=True)
        self.assertEqual(self.workflow_targets[name].read_bytes(), b'updated planning\n')
        backups = list(self.workflows.glob('planning.md.backup.*'))
        self.assertEqual([p.read_bytes() for p in backups], [original])
        self.assert_no_staging()

    @unittest.skipIf(args.powershell, 'POSIX HOME fallback; Windows uses native $HOME')
    def test_default_home_without_codex_home(self):
        self.env.pop('CODEX_HOME')
        self.run_install(copy=True, default_skills=True)
        self.assertEqual((self.home / '.codex' / 'AGENTS.md').read_bytes(), self.source.read_bytes())
        for name, source in self.workflow_sources.items():
            target = self.home / '.agents' / 'workflows' / name
            self.assertEqual(target.read_bytes(), source.read_bytes())
            self.assertFalse(target.is_symlink())
        self.assertTrue((self.home / '.agents' / 'skills' / 'fixture-skill').is_symlink())

    @unittest.skipIf(args.powershell, 'POSIX failure injection; no fake success on Windows')
    def test_staging_failure_leaves_existing_file_untouched(self):
        # Fail only the global AGENTS.md symlink.
        fake_bin = self.base / 'fake bin'
        fake_bin.mkdir()
        real_ln = shutil.which('ln')
        fake_ln = fake_bin / 'ln'
        fake_ln.write_text('#!/bin/sh\ncase "$3" in */.agents-install.*/AGENTS.md) exit 1 ;; esac\n'
                           f'exec "{real_ln}" "$@"\n', encoding='utf-8')
        fake_ln.chmod(0o755)
        self.env['PATH'] = str(fake_bin) + os.pathsep + self.env['PATH']
        self.target.write_text('keep original', encoding='utf-8')
        self.run_install(replace=True, success=False)
        self.assertEqual(self.target.read_text(), 'keep original')
        self.assertEqual(self.backups(), [])
        self.assert_no_staging()

    @unittest.skipIf(args.powershell, 'POSIX failure injection; no fake success on Windows')
    def test_activation_failure_restores_original_file(self):
        fake_bin = self.base / 'fake bin'
        fake_bin.mkdir()
        real_mv = shutil.which('mv')
        fake_mv = fake_bin / 'mv'
        fake_mv.write_text('#!/bin/sh\ncase "$1" in */.agents-install.*/AGENTS.md) exit 1 ;; esac\n'
                           f'exec "{real_mv}" "$@"\n', encoding='utf-8')
        fake_mv.chmod(0o755)
        self.env['PATH'] = str(fake_bin) + os.pathsep + self.env['PATH']
        self.target.write_text('keep original', encoding='utf-8')
        self.run_install(copy=True, replace=True, success=False)
        self.assertEqual(self.target.read_text(), 'keep original')
        self.assertEqual(self.backups(), [])
        self.assert_no_staging()


if __name__ == '__main__':
    unittest.main(argv=[sys.argv[0], *remaining], verbosity=2)
