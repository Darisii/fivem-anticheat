# FiveM AntiCheat System

**Created by D**

An advanced, comprehensive anti-cheat system for FiveM servers with Discord logging, automatic banning, and multiple detection methods.

## Features

### 🛡️ Anti-Cheat Detections
- **God Mode Detection** - Detects unlimited health exploits
- **NoClip Detection** - Detects noclip and wall clipping
- **Speed Hack Detection** - Detects abnormal speed modifications
- **Super Jump Detection** - Detects excessive jump heights
- **Weapon Exploits** - Detects explosive weapon exploits
- **Blacklisted Weapons** - Automatically removes restricted weapons
- **Script Injection Detection** - Basic injection detection
- **Teleport Detection** - Detects unauthorized teleportation
- **Health/Armor Regeneration** - Detects abnormal healing rates
- **Vehicle Spawn Detection** - Detects unauthorized vehicle spawning
- **Blacklisted Models** - Detects restricted player models
- **Resource Manipulation** - Detects suspicious resource activities
- **Infinite Ammo Detection** - Detects unlimited ammo exploits
- **Rapid Fire Detection** - Detects modified fire rates
- **No Recoil Detection** - Detects recoil modifications

### 📋 Management Features
- **Configurable Detections** - Enable/disable specific detections
- **Whitelist System** - Exclude trusted players from checks
- **Auto-Ban System** - Automatic banning with customizable duration
- **Discord Webhook Logging** - Real-time notifications to Discord
- **Admin Commands** - Complete control over the anti-cheat
- **Detection Thresholds** - Configurable sensitivity levels

### 🎯 Admin Commands
```
/ac_ban [playerId] [reason]     - Manually ban a player
/ac_unban [identifier]          - Unban a player
/ac_status                      - Show anti-cheat statistics
/ac_reload                      - Reload configuration
```

## Installation

### 1. Download the Script
Download or clone this repository to your FiveM server's `resources` folder.

### 2. Configure Discord Webhook
1. Create a Discord server for your FiveM community
2. Go to Server Settings → Integrations → Webhooks
3. Create a new webhook and copy the URL
4. Open `config.lua` and replace the webhook URL:
```lua
Config.DiscordWebhook = "https://discord.com/api/webhooks/YOUR_WEBHOOK_HERE"
```

### 3. Configure Settings
Edit `config.lua` to customize:
- Enable/disable specific detections
- Set detection thresholds
- Configure ban duration
- Add whitelisted players
- Customize blacklisted items

### 4. Add to Server
Add the following to your `server.cfg`:
```cfg
ensure anticheat
```

### 5. Set Admin Permissions
Add these permissions to your server.cfg or admin system:
```cfg
add_ace group.anticheat anticheat.ban allow
add_ace group.anticheat anticheat.unban allow
add_ace group.anticheat anticheat.status allow
add_ace group.anticheat anticheat.reload allow
```

Or assign to individual admins:
```cfg
add_ace identifier.license:xxxxxxxxxxxxxxxx anticheat.ban allow
add_ace identifier.license:xxxxxxxxxxxxxxxx anticheat.unban allow
add_ace identifier.license:xxxxxxxxxxxxxxxx anticheat.status allow
add_ace identifier.license:xxxxxxxxxxxxxxxx anticheat.reload allow
```

### 6. Restart Server
Restart your FiveM server to load the anti-cheat system.

## Configuration

### Basic Configuration
```lua
-- Discord Webhook
Config.DiscordWebhook = "https://discord.com/api/webhooks/YOUR_WEBHOOK_HERE"

-- Auto-Ban Settings
Config.AutoBan = true                    -- Enable automatic banning
Config.BanDuration = 0                   -- 0 = permanent, otherwise in hours

-- Detection Settings
Config.Detections = {
    GodMode = true,           -- Enable god mode detection
    NoClip = true,            -- Enable noclip detection
    SpeedHack = true,         -- Enable speed hack detection
    -- ... more settings
}
```

### Whitelist Players
Add trusted players to bypass anti-cheat checks:
```lua
Config.Whitelist = {
    "license:xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx",
    "steam:xxxxxxxxxxxxxxxxxxxxxxxx",
    "discord:xxxxxxxxxxxxxxxxxx",
}
```

### Detection Thresholds
Fine-tune detection sensitivity:
```lua
Config.Thresholds = {
    SpeedMultiplier = 2.0,       -- Max speed multiplier
    JumpHeight = 3.0,            -- Max jump height
    TeleportDistance = 100.0,    -- Max teleport distance
    HealthRegenRate = 5.0,       -- Max health regen per second
    -- ... more thresholds
}
```

## Discord Integration

The anti-cheat sends detailed logs to your Discord channel including:
- 🚨 **Detection Alerts** - Real-time cheat detections
- 🔒 **Ban Notifications** - Automatic ban confirmations
- 👋 **Player Joins** - New player connections
- ⚠️ **System Warnings** - Important system events

Each log includes:
- Player name and ID
- Detection type and details
- Player identifiers (License, Steam, Discord, IP)
- Timestamp and context

## Troubleshooting

### Common Issues

**Q: False bans are occurring**
A: Adjust detection thresholds in `config.lua` or add players to the whitelist.

**Q: Discord webhook not working**
A: Verify the webhook URL is correct and the Discord channel has permission to receive webhooks.

**Q: Anti-cheat not detecting cheats**
A: Ensure the resource is properly loaded and detections are enabled in config.

**Q: Players getting kicked for no reason**
A: Check server console for error messages and verify configuration syntax.

### Debug Mode
Enable debug mode for troubleshooting:
```lua
Config.Debug = true
```

This will output detailed information to the server console.

## Performance

The anti-cheat is optimized for minimal performance impact:
- Efficient detection algorithms
- Configurable check intervals
- Resource-friendly monitoring
- Asynchronous Discord logging

## Compatibility

- **FiveM Version**: Latest (recommended)
- **Framework**: Standalone (works with ESX, QB-Core, etc.)
- **Dependencies**: None required
- **Lua Version**: 5.4 supported

## Security Features

- **Client-Side Protection**: Multiple detection methods
- **Server-Side Validation**: Server-side verification and logging
- **Tamper Detection**: Basic injection and resource manipulation detection
- **Identifier Tracking**: Comprehensive player identification
- **Automatic Banning**: Configurable ban system with reasons

## Support

For support and updates:
- Check the configuration files
- Review server console logs
- Verify Discord webhook settings
- Ensure proper permissions are set

## License

This script is created by D and is provided as-is. Use responsibly and test thoroughly before deployment on production servers.

## Changelog

### v1.0.0
- Initial release
- Core anti-cheat detections
- Discord webhook integration
- Auto-ban system
- Admin commands
- Configuration system
- Whitelist support

---

**Created by D** | FiveM AntiCheat System v1.0.0
