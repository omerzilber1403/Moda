@echo off
echo Applying Chat Fix Migrations...
echo.

node apply_chat_fix_migrations.js

if %ERRORLEVEL% NEQ 0 (
    echo.
    echo Migration script failed. See CHAT_FIX_SUMMARY.md for manual instructions.
    pause
    exit /b %ERRORLEVEL%
)

echo.
echo ========================================
echo  Chat Fix Applied Successfully!
echo ========================================
echo.
echo Next steps:
echo 1. Restart your Flutter app if running
echo 2. Test by making a purchase
echo 3. Check that chat appears in Inbox tab
echo.
pause
