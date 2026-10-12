@echo off
setlocal EnableExtensions EnableDelayedExpansion

for %%I in ("%~dp0..") do set "skill_dir=%%~fI"
set "source_dir=!skill_dir!\agent-profiles"
if defined CODEX_HOME (
  set "codex_home=%CODEX_HOME%"
) else (
  set "codex_home=%USERPROFILE%\.codex"
)
set "target_dir=!codex_home!\agents"

if not exist "!source_dir!\" (
  echo Missing profile directory: !source_dir! 1>&2
  exit /b 1
)

if not exist "!target_dir!\" mkdir "!target_dir!"
if errorlevel 1 exit /b 1

set "found="
for %%F in ("!source_dir!\*.toml") do (
  set "found=1"
  set "profile_name=%%~nxF"
  set "target=!target_dir!\%%~nxF"
  set "temporary=!target!.pocket-engineer.tmp"

  del /f /q "!temporary!" >nul 2>nul
  mklink "!temporary!" "%%~fF" >nul
  if errorlevel 1 goto symlink_failed

  if exist "!target!" del /f /q "!target!"
  move /y "!temporary!" "!target!" >nul
  if errorlevel 1 goto install_failed

  echo Linked !target! -^> %%~fF
)

if not defined found goto no_profiles
exit /b 0

:symlink_failed
echo Failed to create symbolic link for !profile_name!. Enable Windows Developer Mode or run as administrator. 1>&2
exit /b 1

:install_failed
echo Failed to install symbolic link for !profile_name!. 1>&2
exit /b 1

:no_profiles
echo No TOML profiles found in !source_dir! 1>&2
exit /b 1
