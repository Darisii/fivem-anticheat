-- FiveM AntiCheat Installation Script
-- Created by D

local Install = {}

-- Installation function
function Install.Setup()
    print("==========================================")
    print("FiveM AntiCheat Installation")
    print("Created by D")
    print("==========================================")
    print()
    
    -- Check if running in FiveM environment
    if GetConvar('serverName', '') == '' then
        print("ERROR: This script must be run in a FiveM server environment")
        return false
    end
    
    -- Check dependencies
    print("[1/4] Checking dependencies...")
    
    -- Check if essential functions are available
    if not GetResourcePath then
        print("ERROR: Essential FiveM functions not available")
        return false
    end
    
    print("✅ Dependencies OK")
    
    -- Create configuration if not exists
    print("[2/4] Setting up configuration...")
    
    local configPath = GetResourcePath(GetCurrentResourceName()) .. '/config.lua'
    local configFile = LoadResourceFile(GetCurrentResourceName(), 'config.lua')
    
    if not configFile then
        print("ERROR: config.lua not found")
        return false
    end
    
    print("✅ Configuration found")
    
    -- Validate Discord webhook
    print("[3/4] Validating Discord webhook...")
    
    -- Load config to check webhook
    local func = load(configFile)
    if func then
        local config = func()
        
        if config.DiscordWebhook == "https://discord.com/api/webhooks/YOUR_WEBHOOK_HERE" then
            print("⚠️  WARNING: Discord webhook not configured")
            print("Please edit config.lua and add your Discord webhook URL")
            print("You can get one from: Discord Server Settings → Integrations → Webhooks")
        else
            print("✅ Discord webhook configured")
        end
    end
    
    -- Setup admin permissions
    print("[4/4] Setting up admin permissions...")
    print()
    print("Add these permissions to your server.cfg:")
    print("add_ace group.anticheat anticheat.ban allow")
    print("add_ace group.anticheat anticheat.unban allow")
    print("add_ace group.anticheat anticheat.status allow")
    print("add_ace group.anticheat anticheat.reload allow")
    print()
    print("Or add to individual admins:")
    print("add_ace identifier.license:YOUR_LICENSE anticheat.ban allow")
    print("add_ace identifier.license:YOUR_LICENSE anticheat.unban allow")
    print("add_ace identifier.license:YOUR_LICENSE anticheat.status allow")
    print("add_ace identifier.license:YOUR_LICENSE anticheat.reload allow")
    
    -- Installation complete
    print()
    print("==========================================")
    print("✅ INSTALLATION COMPLETE!")
    print("==========================================")
    print()
    print("Next steps:")
    print("1. Add 'ensure anticheat' to your server.cfg")
    print("2. Configure Discord webhook in config.lua")
    print("3. Set admin permissions as shown above")
    print("4. Restart your FiveM server")
    print()
    print("Admin commands:")
    print("/ac_ban [id] [reason] - Ban player")
    print("/ac_unban [identifier] - Unban player")
    print("/ac_status - View statistics")
    print("/ac_reload - Reload configuration")
    print()
    print("Created by D - AntiCheat Ready! 🛡️")
    
    return true
end

-- Auto-install on resource start
Citizen.CreateThread(function()
    Wait(2000) -- Wait for resource to fully load
    
    -- Check if this is first run
    local isFirstRun = GetResourceMetadata(GetCurrentResourceName(), 'first_run', 0) ~= 'false'
    
    if isFirstRun then
        Install.Setup()
        
        -- Mark as installed
        SetResourceMetadata(GetCurrentResourceName(), 'first_run', 'false')
    end
end)

-- Export install function
exports('Install', Install)

-- Manual install command
RegisterCommand('anticheat_install', function(source, args, rawCommand)
    if source == 0 or IsPlayerAceAllowed(source, 'anticheat.admin') then
        Install.Setup()
    else
        TriggerClientEvent('chat:addMessage', source, {
            color = {255, 0, 0},
            multiline = true,
            args = {"AntiCheat", "You don't have permission to use this command"}
        })
    end
end, false)

-- Version check
local function CheckVersion()
    local currentVersion = GetResourceMetadata(GetCurrentResourceName(), 'version', 0)
    print(string.format("[AntiCheat] Version: %s", currentVersion))
    print("[AntiCheat] Created by D")
end

-- Run version check
CheckVersion()
