@set HOME=/home/%USERNAME%
@rem See /etc/profile - it should invoke post-install step 05-home-dir.post
@rem which uses this environment variable to change directories.
@set CHERE_INVOKING=1
%~dp0..\usr\bin\bash.exe -l %*
@rem >> %~dp0logoutput.txt
