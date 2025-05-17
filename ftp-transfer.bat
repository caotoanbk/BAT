@echo off
setlocal enabledelayedexpansion

:: === Working Directory ===
set "WORK_DIR=e:\tmp"

if not exist "%WORK_DIR%" (
    mkdir "%WORK_DIR%"
)
cd /d "%WORK_DIR%"

:: === Get user input ===
set /p FTP_URL=Enter FTP URL (e.g., ftp://ftp.source.com/path/to/file.tar.gz): 
set /p FTP_USER=Enter FTP Username: 
:: set /p FTP_PASS=Enter FTP Password: 
:: === Secure password input ===
:: === Secure password input using PowerShell ===
set FTP_PASS=
for /f "delims=" %%P in ('powershell -Command "$p = Read-Host 'Enter FTP Password' -AsSecureString; [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($p))"') do set "FTP_PASS=%%P"

:: === Extract filename from URL ===
for %%F in (%FTP_URL%) do set "FILE_NAME=%%~nxF"

echo.
echo Downloading file...
curl -u "%FTP_USER%:%FTP_PASS%" -o "%FILE_NAME%" "%FTP_URL%"

if not exist "%FILE_NAME%" (
    echo Download failed. File not found.
    pause
    exit /b 1
)

echo %FILE_NAME%
:: Set upload URL (encoded spaces)
set "UPLOAD_URL=ftp://10.224.20.210/Hai%%20Phong%%20Factory/99_Personal/toan2.cao/tmp"

echo Uploading file to target FTP...
echo %UPLOAD_URL%
curl -u "%FTP_USER%:%FTP_PASS%" --ftp-create-dirs -T "%FILE_NAME%" "%UPLOAD_URL%/%FILE_NAME%"


if %ERRORLEVEL% NEQ 0 (
    echo Upload failed.
    pause
    exit /b 1
)

:: === Show download command for reuse ===
echo.
echo Done!
echo curl -u "%FTP_USER%:%FTP_PASS%" -o "%FILE_NAME%" "%UPLOAD_URL%/%FILE_NAME%" | clip
echo Download command copied to clipboard!

