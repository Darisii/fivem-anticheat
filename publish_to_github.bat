@echo off
echo ==========================================
echo FiveM AntiCheat - GitHub Publisher
echo Created by D
echo ==========================================
echo.

REM Check if git is installed
git --version >nul 2>&1
if %errorlevel% neq 0 (
    echo ERROR: Git is not installed or not in PATH
    echo Please install Git from https://git-scm.com/
    pause
    exit /b 1
)

echo [1/5] Initializing Git repository...
git init
if %errorlevel% neq 0 (
    echo ERROR: Failed to initialize git repository
    pause
    exit /b 1
)

echo [2/5] Adding all files...
git add .
if %errorlevel% neq 0 (
    echo ERROR: Failed to add files
    pause
    exit /b 1
)

echo [3/5] Creating initial commit...
git commit -m "Initial commit: FiveM AntiCheat System by D
- Complete anti-cheat protection system
- Discord webhook logging
- Auto-ban system with configurable settings
- Multiple detection methods (godmode, noclip, speedhack, etc.)
- Admin commands and whitelist system
- Ready to use FiveM resource"
if %errorlevel% neq 0 (
    echo ERROR: Failed to create commit
    pause
    exit /b 1
)

echo.
echo ==========================================
echo SUCCESS! Repository is ready for GitHub!
echo ==========================================
echo.
echo NEXT STEPS:
echo 1. Go to GitHub.com and create a new repository named "fivem-anticheat"
echo 2. Copy the repository URL (https://github.com/username/fivem-anticheat.git)
echo 3. Run: git remote add origin YOUR_REPOSITORY_URL
echo 4. Run: git push -u origin main
echo.
echo Or create a GitHub repository first and then run this script again.
echo.

pause
