@echo off
setlocal enabledelayedexpansion

:: === Get user input ===
set /p RAW_URL=Enter local file location: 
echo %RAW_URL%test
:: Sanitize: remove username if embedded in the URL (e.g., ftp://user@host -> ftp://host)
for /f "tokens=1,* delims=@" %%a in ("%RAW_URL%") do (
    set "FTP_URL=%%a"
    if not "%%b"=="" set "FTP_URL=ftp://%%b"
)
:: Trim leading/trailing spaces
for /f "tokens=* delims=" %%A in ("%FTP_URL%") do set "FTP_URL=%%A"

:: Trim trailing spaces by loop
:trim_end
if "!FTP_URL:~-1!"==" " (
    set "FTP_URL=!FTP_URL:~0,-1!"
    goto trim_end
)

set /p FTP_USER=Enter FTP Username: 
:: === Secure password input using PowerShell ===
set FTP_PASS=
for /f "delims=" %%P in ('powershell -Command "$p = Read-Host 'Enter FTP Password' -AsSecureString; [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($p))"') do set "FTP_PASS=%%P"

:: === Extract filename from URL ===
for %%F in (%FTP_URL%) do set "FILE_NAME=%%~nxF"

echo.

:: Set upload URL (encoded spaces)
set "UPLOAD_URL=ftp://10.224.20.210/Hai%%20Phong%%20Factory/99_Personal/toan2.cao/tmp"
::set "UPLOAD_URL=ftp://10.158.10.47/icon-temp/tmp"

echo Uploading file to target FTP...
echo %UPLOAD_URL%
curl -u "%FTP_USER%:%FTP_PASS%" --ftp-create-dirs -T "%FILE_NAME%" "%UPLOAD_URL%/%FILE_NAME%"


if %ERRORLEVEL% NEQ 0 (
    echo Upload failed.
    pause
    exit /b 1
)

:: === Show info ===
echo.
echo Done! 
echo FTP URL:
echo "%UPLOAD_URL%/%FILE_NAME%"
echo "%UPLOAD_URL%/%FILE_NAME%" | clip
echo FTP URL copied to clipboard!

