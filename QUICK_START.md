# 🚀 Quick Start Guide

## One-Click GitHub Publishing

### Method 1: Use the Publisher Script
1. Double-click `publish_to_github.bat`
2. Follow the on-screen instructions
3. Create a GitHub repository and push

### Method 2: Manual Commands
```bash
git init
git add .
git commit -m "Initial commit: FiveM AntiCheat System"
git remote add origin https://github.com/username/fivem-anticheat.git
git push -u origin main
```

## Server Installation

1. **Download** the anti-cheat from GitHub
2. **Extract** to your `resources` folder
3. **Configure** Discord webhook in `config.lua`
4. **Add** to `server.cfg`: `ensure anticheat`
5. **Restart** your server

## Discord Setup

1. Create Discord server webhook
2. Copy webhook URL
3. Paste in `config.lua` line 7
4. Restart resource with `/ac_reload`

## Admin Commands

- `/ac_ban [id] [reason]` - Ban player
- `/ac_status` - View statistics
- `/ac_reload` - Reload config

**Created by D** | Ready in 2 minutes! ⚡
