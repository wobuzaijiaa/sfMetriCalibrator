@echo off
setlocal EnableExtensions

rem Run from this release directory, regardless of the caller's working directory.
cd /d "%~dp0"
if errorlevel 1 (
    echo ERROR: Cannot access the release directory.
    pause
    exit /b 1
)

set "VENV_PY=%~dp0.venv\Scripts\python.exe"
set "WHEEL="

rem Require Python 3.12 to match the current development environment.
if not exist "%VENV_PY%" (
    where py >nul 2>nul
    if errorlevel 1 (
        echo ERROR: Python Launcher ^(py.exe^) was not found.
        echo Install 64-bit Python 3.12 and enable the Python Launcher.
        pause
        exit /b 1
    )

    py -3.12 -m venv "%~dp0.venv"
    if errorlevel 1 (
        echo ERROR: Could not create the virtual environment with Python 3.12.
        echo Confirm that Python 3.12 is installed and available through "py -3.12".
        pause
        exit /b 1
    )
)

rem Select the wheel copied beside this launcher.
for %%F in ("%~dp0*.whl") do (
    if exist "%%~fF" set "WHEEL=%%~fF"
)

if not defined WHEEL (
    echo ERROR: No .whl file was found beside launch.bat.
    echo Copy the built SFM Metric Calibrator wheel into this directory.
    pause
    exit /b 1
)

rem Install the local wheel and any missing/required dependencies.
rem Without --force-reinstall, pip leaves an already-satisfied environment intact.
"%VENV_PY%" -m pip install --disable-pip-version-check "%WHEEL%"
if errorlevel 1 (
    echo.
    echo ERROR: Installation failed. Check internet access and package compatibility.
    pause
    exit /b 1
)

"%VENV_PY%" -m metricalibrator
set "APP_EXIT=%ERRORLEVEL%"

if not "%APP_EXIT%"=="0" (
    echo.
    echo The application exited with code %APP_EXIT%.
    pause
)

exit /b %APP_EXIT%
