@ECHO OFF
PATH=C:\Program Files\Python313;C:\Program Files\Python313\Scripts;%PATH%
IF "%1"=="/INIT" GOTO InitializeEnvironment
PUSHD "%~dp0"

ECHO.
ECHO Checking current python.exe location(s)
where python.exe
where pip.exe
where pyinstaller.exe

ECHO.
ECHO Version info for Python/pip/pyinstaller:
python.exe --version
pip.exe --version
pyinstaller.exe --version

ECHO.
ECHO Testing if current git-restore-mtime Python script works...
python.exe ..\git-restore-mtime --version

REM pyinstaller uses upx by default to compress the executable
REM When running the created executable this results in an error:
REM    git-restore-mtime.exe - Bad Image: %TEMP%\VCRUNTIME140.dll
REM        is either not designed to run on Windows or it contains an error (..)
REM Therefore run pyinstaller with the --noupx parameter
ECHO.
ECHO Running pyinstaller to create git-restore-mtime.exe...
pyinstaller.exe -F --noupx ..\git-restore-mtime

ECHO.
ECHO Testing if git-restore-mtime.exe works...
dist\git-restore-mtime.exe --version

PAUSE
GOTO :EOF

:InitializeEnvironment
REM Testing if batch file is running with elevated privileges
NET FILE 1>NUL 2>NUL
IF '%errorlevel%' == '0' (
  ECHO Script %~dpfx0 is running with elevated privileges. Parameters: %1 %2 %3 %4 %5 %6 %7 %8 %9
) ELSE ( 
  ECHO.
  ECHO NOTE: This script needs to run as administrator, it will attempt to self elevate when necessary.
  ECHO Press a key to use Microsoft winget to install Python and the required Python packages...
  PAUSE
  SETLOCAL EnableDelayedExpansion
  GOTO :selfElevateBatchFile
)

REM Everything below here only runs if elevated privileges are available
ECHO.
ECHO Installing/updating Python...
winget install --exact --id Python.Python.3.13 --scope machine --force --accept-package-agreements

ECHO.
ECHO Upgrading pip and setuptools to latest version...
pip.exe install --upgrade --trusted-host pypi.org --trusted-host files.pythonhosted.org pip setuptools

ECHO.
ECHO Installing latest version of pyinstaller...
pip.exe install --trusted-host pypi.org --trusted-host files.pythonhosted.org ^
  https://github.com/pyinstaller/pyinstaller/archive/develop.tar.gz

ECHO.
ECHO Finished!
PAUSE
GOTO :EOF

:selfElevateBatchFile
ECHO.
ECHO **************************************
ECHO Invoking UAC for Privilege Escalation
ECHO **************************************
ECHO Set UAC = CreateObject^("Shell.Application"^) > "%temp%\OEgetPrivileges.vbs"
ECHO UAC.ShellExecute "%~dpfx0", "%1 %2 %3 %4 %5 %6 %7 %8 %9", "", "runas", 1 >> "%temp%\OEgetPrivileges.vbs"
"%temp%\OEgetPrivileges.vbs"
REM Close the batch file; it will be restarted with elevated privileges
GOTO :EOF
