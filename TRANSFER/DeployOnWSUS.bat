@echo off
setlocal

rem Folder Package D:\MS_updates_package
rem Default Home Folder of SecPkg E:\WSUS

rem Change location of WSUS home dir
set WSUS_HOME=E:\WSUS
if "%1" EQU "" goto INSTALL
set WSUS_HOME=%1\WSUS

:INSTALL
echo copying updates binaries...
if exist %WSUS_HOME%\WsusContent goto COPYFILES
echo ERROR: Path not found - %WSUS_HOME%\WsusContent
goto END

:COPYFILES
rem COPING WSUS UPDATES
robocopy .\Updates\WsusContent %WSUS_HOME%\WsusContent /E
rem if errorlevel 1 (echo ERROR: Copy of WSUS updates failed & goto FAIL)
echo Done! Updates copied to E:\WSUS\WsusContent

rem Stopping Starting Services:
echo Stopping service 'World Wide Web Publishing Service...'
net stop w3svc
echo Done
echo Starting service 'World Wide Web Publishing Service...'
net start w3svc
echo Done

rem IMPORTING WSUS META UPDATES
echo Importing metadata. This can take many Hours...
set WSUSUTIL="%ProgramFiles%\Update Services\Tools\wsusutil.exe"
%WSUSUTIL% import Updates\WSUS-Export.xml.gz WSUS-Import.log
if errorlevel 1 (echo ERROR: Import failed & goto FAIL)
echo Done

rem APPROVING UPDATES ON WSUS SERVER...
echo Approving relevant updates on WSUS server...
Powershell.exe -File ApproveAll.ps1
echo Done

:FAIL
pause
pause