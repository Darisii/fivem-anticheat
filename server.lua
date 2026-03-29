-- FiveM AntiCheat Server Side
-- Created by D

local Config = {}
local PlayerDetections = {}
local BannedPlayers = {}
local IsInitialized = false

-- Load configuration
function LoadConfig()
    local configFile = LoadResourceFile(GetCurrentResourceName(), 'config.lua')
    if configFile then
        local func = load(configFile)
        if func then
            Config = func()
            IsInitialized = true
            print("[AntiCheat] Configuration loaded successfully")
        else
            print("[AntiCheat] Error loading configuration")
        end
    end
end

-- Load config on resource start
Citizen.CreateThread(function()
    LoadConfig()
end)

-- Export config for client side
exports('GetConfig', function()
    return Config
end)

-- Send Discord webhook
local function SendDiscordWebhook(title, description, color, fields)
    if not Config.DiscordWebhook or Config.DiscordWebhook == "https://discord.com/api/webhooks/YOUR_WEBHOOK_HERE" then
        return
    end
    
    local embed = {
        title = title,
        description = description,
        color = color or Config.DiscordColor,
        timestamp = os.date("!%Y-%m-%dT%H:%M:%S"),
        footer = {
            text = "FiveM AntiCheat by D"
        },
        fields = fields or {}
    }
    
    PerformHttpRequest(Config.DiscordWebhook, function(err, text, headers)
        if err ~= 200 then
            print("[AntiCheat] Discord webhook error: " .. tostring(err))
        end
    end, 'POST', json.encode({
        username = Config.DiscordTitle,
        embeds = {embed}
    }), {
        ['Content-Type'] = 'application/json'
    })
end

-- Format identifiers for display
local function FormatIdentifiers(identifiers)
    local formatted = {}
    for _, id in ipairs(identifiers) do
        local type = string.sub(id, 1, string.find(id, ":") - 1)
        local value = string.sub(id, string.find(id, ":") + 1)
        
        if type == "license" then
            table.insert(formatted, "**License:** " .. value)
        elseif type == "steam" then
            table.insert(formatted, "**Steam:** " .. value)
        elseif type == "discord" then
            table.insert(formatted, "**Discord:** <@" .. value .. ">")
        elseif type == "ip" then
            table.insert(formatted, "**IP:** " .. value)
        end
    end
    return table.concat(formatted, "\n")
end

-- Get player name
local function GetPlayerName(source)
    local name = GetPlayerName(source)
    if not name then
        name = "Unknown"
    end
    return name
end

-- Ban player
local function BanPlayer(source, reason, detectionData)
    if not Config.AutoBan then return end
    
    local playerName = GetPlayerName(source)
    local identifiers = {}
    
    -- Get all player identifiers
    for i = 0, GetNumPlayerIdentifiers(source) - 1 do
        local identifier = GetPlayerIdentifier(source, i)
        if identifier then
            table.insert(identifiers, identifier)
        end
    end
    
    -- Add to banned players list
    BannedPlayers[source] = {
        name = playerName,
        reason = reason,
        identifiers = identifiers,
        timestamp = os.time(),
        detectionData = detectionData
    }
    
    -- Log ban to Discord
    if Config.LogBans then
        local fields = {
            {
                name = "Player",
                value = playerName,
                inline = true
            },
            {
                name = "Reason",
                value = reason,
                inline = true
            },
            {
                name = "Identifiers",
                value = FormatIdentifiers(identifiers),
                inline = false
            }
        }
        
        if detectionData then
            table.insert(fields, {
                name = "Detection Data",
                value = "```json\n" .. json.encode(detectionData) .. "\n```",
                inline = false
            })
        end
        
        SendDiscordWebhook(
            "🔒 Player Banned",
            string.format(Config.Messages.Ban, playerName, reason),
            16711680,
            fields
        )
    end
    
    -- Execute ban
    local banDuration = Config.BanDuration
    if banDuration == 0 then
        -- Permanent ban
        BanIdentifier(source, reason, identifiers)
    else
        -- Temporary ban
        BanIdentifier(source, reason, identifiers, banDuration)
    end
    
    -- Kick player
    DropPlayer(source, string.format("You have been banned for: %s", reason))
    
    print(string.format("[AntiCheat] Banned player %s for: %s", playerName, reason))
end

-- Handle detection from client
RegisterServerEvent('anticheat:detection')
AddEventHandler('anticheat:detection', function(detectionType, data, identifiers)
    local source = source
    
    if not IsInitialized then return end
    
    -- Check if detection is enabled
    if not Config.Detections[detectionType] then return end
    
    local playerName = GetPlayerName(source)
    
    -- Initialize player detections if not exists
    if not PlayerDetections[source] then
        PlayerDetections[source] = {}
    end
    
    -- Add detection
    PlayerDetections[source][detectionType] = (PlayerDetections[source][detectionType] or 0) + 1
    
    -- Log detection to Discord
    if Config.LogDetections then
        local fields = {
            {
                name = "Player",
                value = playerName,
                inline = true
            },
            {
                name = "Detection Type",
                value = detectionType,
                inline = true
            },
            {
                name = "Count",
                value = tostring(PlayerDetections[source][detectionType]),
                inline = true
            }
        }
        
        if data then
            table.insert(fields, {
                name = "Detection Data",
                value = "```json\n" .. json.encode(data) .. "\n```",
                inline = false
            })
        end
        
        SendDiscordWebhook(
            "🚨 Anti-Cheat Detection",
            string.format(Config.Messages.Detection, detectionType),
            16776960,
            fields
        )
    end
    
    -- Check for auto-ban threshold
    local detectionCount = PlayerDetections[source][detectionType]
    local banThreshold = 3 -- Ban after 3 detections of the same type
    
    if detectionCount >= banThreshold then
        BanPlayer(source, string.format("Multiple %s detections", detectionType), {
            type = detectionType,
            count = detectionCount,
            data = data
        })
    end
    
    -- Log to console
    print(string.format("[AntiCheat] Detection from %s: %s (Count: %d)", playerName, detectionType, detectionCount))
end)

-- Handle player ready event
RegisterServerEvent('anticheat:playerReady')
AddEventHandler('anticheat:playerReady', function()
    local source = source
    
    if not IsInitialized then return end
    
    local playerName = GetPlayerName(source)
    
    -- Log player join to Discord
    if Config.LogJoins then
        local identifiers = {}
        for i = 0, GetNumPlayerIdentifiers(source) - 1 do
            local identifier = GetPlayerIdentifier(source, i)
            if identifier then
                table.insert(identifiers, identifier)
            end
        end
        
        local fields = {
            {
                name = "Player",
                value = playerName,
                inline = true
            },
            {
                name = "ID",
                value = tostring(source),
                inline = true
            },
            {
                name = "Identifiers",
                value = FormatIdentifiers(identifiers),
                inline = false
            }
        }
        
        SendDiscordWebhook(
            "👋 Player Joined",
            string.format(Config.Messages.Join, playerName),
            65280,
            fields
        )
    end
    
    print(string.format("[AntiCheat] Player %s (%d) ready", playerName, source))
end)

-- Handle player disconnect
AddEventHandler('playerDropped', function(reason)
    local source = source
    
    if PlayerDetections[source] then
        PlayerDetections[source] = nil
    end
    
    if BannedPlayers[source] then
        BannedPlayers[source] = nil
    end
end)

-- Admin commands
RegisterCommand('ac_ban', function(source, args, rawCommand)
    if source == 0 or IsPlayerAceAllowed(source, 'anticheat.ban') then
        if #args >= 2 then
            local targetId = tonumber(args[1])
            local reason = table.concat(args, " ", 2)
            
            if targetId and GetPlayerName(targetId) then
                BanPlayer(targetId, reason, {
                    type = 'manual',
                    admin = source == 0 and "Console" or GetPlayerName(source)
                })
            else
                local message = source == 0 and "Invalid player ID" or "Invalid player ID"
                TriggerClientEvent('chat:addMessage', source, {
                    color = {255, 0, 0},
                    multiline = true,
                    args = {"AntiCheat", message}
                })
            end
        else
            local message = source == 0 and "Usage: /ac_ban [playerId] [reason]" or "Usage: /ac_ban [playerId] [reason]"
            TriggerClientEvent('chat:addMessage', source, {
                color = {255, 255, 0},
                multiline = true,
                args = {"AntiCheat", message}
            })
        end
    end
end, false)

RegisterCommand('ac_unban', function(source, args, rawCommand)
    if source == 0 or IsPlayerAceAllowed(source, 'anticheat.unban') then
        if #args >= 1 then
            local identifier = args[1]
            
            -- Remove ban (this would need to be implemented based on your ban system)
            -- For now, we'll just log it
            print(string.format("[AntiCheat] Unban request for %s by %s", identifier, source == 0 and "Console" or GetPlayerName(source)))
            
            local message = source == 0 and "Unban request processed" or "Unban request processed"
            TriggerClientEvent('chat:addMessage', source, {
                color = {0, 255, 0},
                multiline = true,
                args = {"AntiCheat", message}
            })
        else
            local message = source == 0 and "Usage: /ac_unban [identifier]" or "Usage: /ac_unban [identifier]"
            TriggerClientEvent('chat:addMessage', source, {
                color = {255, 255, 0},
                multiline = true,
                args = {"AntiCheat", message}
            })
        end
    end
end, false)

RegisterCommand('ac_status', function(source, args, rawCommand)
    if source == 0 or IsPlayerAceAllowed(source, 'anticheat.status') then
        local status = {
            initialized = IsInitialized,
            totalDetections = 0,
            bannedPlayers = 0,
            activePlayers = #GetPlayers()
        }
        
        -- Count total detections
        for _, player in pairs(PlayerDetections) do
            for _, count in pairs(player) do
                status.totalDetections = status.totalDetections + count
            end
        end
        
        -- Count banned players
        for _ in pairs(BannedPlayers) do
            status.bannedPlayers = status.bannedPlayers + 1
        end
        
        local statusText = string.format("AntiCheat Status:\nInitialized: %s\nActive Players: %d\nTotal Detections: %d\nBanned Players: %d",
            tostring(status.initialized),
            status.activePlayers,
            status.totalDetections,
            status.bannedPlayers
        )
        
        if source == 0 then
            print("[AntiCheat] " .. statusText)
        else
            TriggerClientEvent('chat:addMessage', source, {
                color = {0, 255, 255},
                multiline = true,
                args = {"AntiCheat", statusText}
            })
        end
    end
end, false)

RegisterCommand('ac_reload', function(source, args, rawCommand)
    if source == 0 or IsPlayerAceAllowed(source, 'anticheat.reload') then
        LoadConfig()
        
        local message = "Configuration reloaded"
        if source == 0 then
            print("[AntiCheat] " .. message)
        else
            TriggerClientEvent('chat:addMessage', source, {
                color = {0, 255, 0},
                multiline = true,
                args = {"AntiCheat", message}
            })
        end
        
        -- Notify all clients to reload config
        TriggerClientEvent('anticheat:reloadConfig', -1)
    end
end, false)

-- Handle config reload on client
RegisterServerEvent('anticheat:reloadConfig')
AddEventHandler('anticheat:reloadConfig', function()
    local source = source
    TriggerClientEvent('anticheat:reloadConfig', source)
end)

-- Check for banned players on connection
AddEventHandler('playerConnecting', function()
    local source = source
    
    if not IsInitialized then return end
    
    local identifiers = {}
    for i = 0, GetNumPlayerIdentifiers(source) - 1 do
        local identifier = GetPlayerIdentifier(source, i)
        if identifier then
            table.insert(identifiers, identifier)
        end
    end
    
    -- Check if player is banned (this would need to be implemented based on your ban system)
    -- For now, we'll just check against our local banned players list
    for _, bannedId in ipairs(identifiers) do
        for _, bannedPlayer in pairs(BannedPlayers) do
            for _, id in ipairs(bannedPlayer.identifiers) do
                if id == bannedId then
                    CancelEvent()
                    TriggerClientEvent('chat:addMessage', source, {
                        color = {255, 0, 0},
                        multiline = true,
                        args = {"AntiCheat", "You are banned from this server"}
                    })
                    return
                end
            end
        end
    end
end)

-- Initialize on resource start
AddEventHandler('onResourceStart', function(resourceName)
    if resourceName == GetCurrentResourceName() then
        print("[AntiCheat] Server side initialized")
        LoadConfig()
    end
end)

-- Cleanup on resource stop
AddEventHandler('onResourceStop', function(resourceName)
    if resourceName == GetCurrentResourceName() then
        print("[AntiCheat] Resource stopping")
    end
end)
