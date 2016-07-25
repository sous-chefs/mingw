@echo off
set HOME=/home/%USERNAME%

rem See /etc/profile.d/custom_pkg_config.sh - it should prepend this value
rem to PKG_CONFIG_PATH after MSYS2 modifies it in /etc/profile.
IF DEFINED PKG_CONFIG_PATH set ORIGINAL_PKG_CONFIG_PATH=%PKG_CONFIG_PATH%

IF "%MSYSTEM%"=="" (
  echo MSYSTEM is NOT defined
  exit
)

rem See /etc/profile - it should invoke post-install step 05-home-dir.post
rem which uses this environment variable to change directories.
set CHERE_INVOKING=1

%~dp0..\usr\bin\bash.exe -l %*
