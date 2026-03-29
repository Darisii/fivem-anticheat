-- FiveM AntiCheat Configuration
-- Created by D

local Config = {}

-- Discord Webhook Settings
Config.DiscordWebhook = "https://discord.com/api/webhooks/YOUR_WEBHOOK_HERE" -- Replace with your Discord webhook URL
Config.DiscordTitle = "🛡️ FiveM AntiCheat"
Config.DiscordColor = 16711680 -- Red color in decimal

-- Detection Settings (true = enabled, false = disabled)
Config.Detections = {
    GodMode = true,           -- Detect god mode
    NoClip = true,            -- Detect noclip
    SpeedHack = true,         -- Detect speed hacks
    SuperJump = true,         -- Detect super jump
    WeaponExplosions = true,  -- Detect weapon explosion exploits
    BlacklistedWeapons = true,-- Detect blacklisted weapons
    Injection = true,         -- Detect script injections
    Teleport = true,          -- Detect teleportation
    HealthRegen = true,       -- Detect abnormal health regeneration
    ArmorRegen = true,        -- Detect abnormal armor regeneration
    VehicleSpawn = true,      -- Detect unauthorized vehicle spawning
    BlacklistedModels = true, -- Detect blacklisted player models
    ResourceStop = true,      -- Detect resource stop attempts
    ResourceStart = true,     -- Detect unauthorized resource starts
    NUIDevTools = true,       -- Detect NUI dev tools
    Freecam = true,           -- Detect freecam
    Spectate = true,          -- Detect spectate modes
    InfiniteAmmo = true,      -- Detect infinite ammo
    NoRecoil = true,          -- Detect no recoil
    RapidFire = true,         -- Detect rapid fire
}

-- Ban Settings
Config.AutoBan = true                    -- Enable automatic banning
Config.BanDuration = 0                   -- 0 = permanent ban, otherwise in hours
Config.BanReason = "Anti-Cheat Violation" -- Default ban reason
Config.LogBans = true                   -- Log bans to Discord
Config.LogDetections = true             -- Log detections to Discord
Config.LogJoins = true                  -- Log player joins to Discord

-- Detection Thresholds
Config.Thresholds = {
    SpeedMultiplier = 2.0,       -- Max speed multiplier before detection
    JumpHeight = 3.0,            -- Max jump height before detection
    TeleportDistance = 100.0,    -- Max teleport distance before detection
    HealthRegenRate = 5.0,       -- Max health regen per second
    ArmorRegenRate = 5.0,        -- Max armor regen per second
    RapidFireDelay = 100,        -- Min delay between shots (ms)
}

-- Whitelist (players that bypass anti-cheat)
Config.Whitelist = {
    -- Add license identifiers here
    -- "license:xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx",
    -- "steam:xxxxxxxxxxxxxxxxxxxxxxxx",
}

-- Blacklisted Items
Config.BlacklistedWeapons = {
    "WEAPON_RAILGUN",
    "WEAPON_RPG",
    "WEAPON_HOMINGLAUNCHER",
    "WEAPON_GRENADELAUNCHER",
    "WEAPON_MINIGUN",
    "WEAPON_RAYMINIGUN",
    "WEAPON_RAYCARBINE",
    "WEAPON_RAYPISTOL",
}

Config.BlacklistedModels = {
    "u_m_y_juggernaut_01",
    "s_m_y_swat_01",
    "a_m_y_mexthug_01",
}

-- Detection Intervals (in milliseconds)
Config.CheckIntervals = {
    Health = 1000,      -- Health check interval
    Armor = 1000,       -- Armor check interval
    Speed = 500,        -- Speed check interval
    Position = 2000,    -- Position check interval
    Weapons = 1000,     -- Weapon check interval
    Resources = 5000,   -- Resource check interval
}

-- Message Settings
Config.Messages = {
    Detection = "🚨 Anti-Cheat Detection: %s",
    Ban = "🔒 Player %s has been banned for: %s",
    Join = "👋 Player %s has joined the server",
    Warning = "⚠️ Warning: %s",
}

-- Debug Settings
Config.Debug = false -- Enable debug messages (only for development)

return Config
