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
ECHO.
ECHO NOTE: This script needs to run as administrator
ECHO Press a key to use Microsoft winget to install Python and the required Python packages...
PAUSE

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
