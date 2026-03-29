-- FiveM AntiCheat Client Side
-- Created by D

local Config = {}
local PlayerData = {}
local LastPosition = {}
local LastHealth = 0
local LastArmor = 0
local LastSpeed = 0
local LastWeapon = nil
local DetectionCount = {}
local IsInitialized = false

-- Load configuration
Citizen.CreateThread(function()
    Config = exports['anticheat']:GetConfig()
    Wait(1000)
    IsInitialized = true
end)

-- Get player identifiers
local function GetPlayerIdentifiers()
    local identifiers = {}
    for i = 0, GetNumPlayerIdentifiers(PlayerId()) - 1 do
        local identifier = GetPlayerIdentifier(PlayerId(), i)
        if identifier then
            table.insert(identifiers, identifier)
        end
    end
    return identifiers
end

-- Send detection to server
local function SendDetection(detectionType, data)
    if not IsInitialized then return end
    
    local identifiers = GetPlayerIdentifiers()
    TriggerServerEvent('anticheat:detection', detectionType, data, identifiers)
    
    -- Increment detection count
    DetectionCount[detectionType] = (DetectionCount[detectionType] or 0) + 1
    
    if Config.Debug then
        print(string.format("[AntiCheat] Detection: %s", detectionType))
    end
end

-- Check if player is whitelisted
local function IsWhitelisted()
    local identifiers = GetPlayerIdentifiers()
    for _, id in ipairs(identifiers) do
        for _, whitelistId in ipairs(Config.Whitelist) do
            if id == whitelistId then
                return true
            end
        end
    end
    return false
end

-- Health monitoring
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(Config.CheckIntervals.Health)
        
        if not IsInitialized or IsWhitelisted() then goto continue end
        if not Config.Detections.GodMode then goto continue end
        
        local ped = PlayerPedId()
        local health = GetEntityHealth(ped)
        
        if LastHealth > 0 and health > LastHealth then
            local regenRate = health - LastHealth
            if regenRate > Config.Thresholds.HealthRegenRate then
                SendDetection('HealthRegen', {
                    rate = regenRate,
                    current = health,
                    previous = LastHealth
                })
            end
        end
        
        if health > 200 then
            SendDetection('GodMode', {
                health = health,
                max = 200
            })
        end
        
        LastHealth = health
        
        ::continue::
    end
end)

-- Armor monitoring
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(Config.CheckIntervals.Armor)
        
        if not IsInitialized or IsWhitelisted() then goto continue end
        if not Config.Detections.ArmorRegen then goto continue end
        
        local ped = PlayerPedId()
        local armor = GetPedArmour(ped)
        
        if LastArmor > 0 and armor > LastArmor then
            local regenRate = armor - LastArmor
            if regenRate > Config.Thresholds.ArmorRegenRate then
                SendDetection('ArmorRegen', {
                    rate = regenRate,
                    current = armor,
                    previous = LastArmor
                })
            end
        end
        
        if armor > 100 then
            SendDetection('ArmorExploit', {
                armor = armor,
                max = 100
            })
        end
        
        LastArmor = armor
        
        ::continue::
    end
end)

-- Speed monitoring
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(Config.CheckIntervals.Speed)
        
        if not IsInitialized or IsWhitelisted() then goto continue end
        if not Config.Detections.SpeedHack then goto continue end
        
        local ped = PlayerPedId()
        local pos = GetEntityCoords(ped)
        local speed = GetEntitySpeed(ped)
        
        -- Convert to km/h for comparison
        local speedKmh = speed * 3.6
        
        -- Check if in vehicle
        if IsPedInAnyVehicle(ped, false) then
            local vehicle = GetVehiclePedIsIn(ped, false)
            local maxSpeed = GetVehicleModelMaxSpeed(GetEntityModel(vehicle)) * 3.6
            
            if speedKmh > maxSpeed * Config.Thresholds.SpeedMultiplier then
                SendDetection('SpeedHack', {
                    speed = speedKmh,
                    maxSpeed = maxSpeed,
                    multiplier = speedKmh / maxSpeed
                })
            end
        else
            -- Check running speed
            if speedKmh > 30 * Config.Thresholds.SpeedMultiplier then
                SendDetection('SpeedHack', {
                    speed = speedKmh,
                    type = 'foot'
                })
            end
        end
        
        LastSpeed = speed
        
        ::continue::
    end
end)

-- Position monitoring (teleport detection)
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(Config.CheckIntervals.Position)
        
        if not IsInitialized or IsWhitelisted() then goto continue end
        if not Config.Detections.Teleport then goto continue end
        
        local ped = PlayerPedId()
        local pos = GetEntityCoords(ped)
        
        if LastPosition.x and LastPosition.y and LastPosition.z then
            local distance = #(pos - LastPosition)
            local time = Config.CheckIntervals.Position / 1000
            
            -- Calculate possible max distance based on speed
            local maxDistance = LastSpeed * time * 1.5 -- Add some tolerance
            
            if distance > Config.Thresholds.TeleportDistance and distance > maxDistance then
                -- Check if player just teleported (not in vehicle, not dead)
                if not IsPedInAnyVehicle(ped, false) and not IsPedDeadOrDying(ped) then
                    SendDetection('Teleport', {
                        distance = distance,
                        from = LastPosition,
                        to = pos,
                        speed = LastSpeed
                    })
                end
            end
        end
        
        LastPosition = pos
        
        ::continue::
    end
end)

-- Weapon monitoring
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(Config.CheckIntervals.Weapons)
        
        if not IsInitialized or IsWhitelisted() then goto continue end
        
        local ped = PlayerPedId()
        local currentWeapon = GetSelectedPedWeapon(ped)
        
        -- Check for blacklisted weapons
        if Config.Detections.BlacklistedWeapons then
            for _, weapon in ipairs(Config.BlacklistedWeapons) do
                if currentWeapon == GetHashKey(weapon) then
                    SendDetection('BlacklistedWeapon', {
                        weapon = weapon,
                        hash = currentWeapon
                    })
                    RemoveWeaponFromPed(ped, currentWeapon)
                end
            end
        end
        
        -- Check for rapid fire
        if Config.Detections.RapidFire and LastWeapon then
            if currentWeapon == LastWeapon then
                local timeSinceLastShot = GetGameTimer() - (LastShotTime or 0)
                if timeSinceLastShot < Config.Thresholds.RapidFireDelay then
                    SendDetection('RapidFire', {
                        weapon = currentWeapon,
                        delay = timeSinceLastShot
                    })
                end
            end
        end
        
        LastWeapon = currentWeapon
        
        ::continue::
    end
end)

-- Track shooting for rapid fire detection
local LastShotTime = 0
AddEventHandler('CEventGunShot', function()
    if not IsInitialized or IsWhitelisted() then return end
    
    local currentTime = GetGameTimer()
    local timeSinceLastShot = currentTime - LastShotTime
    
    if Config.Detections.RapidFire and timeSinceLastShot < Config.Thresholds.RapidFireDelay then
        SendDetection('RapidFire', {
            delay = timeSinceLastShot
        })
    end
    
    LastShotTime = currentTime
end)

-- NoClip detection
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(1000)
        
        if not IsInitialized or IsWhitelisted() then goto continue end
        if not Config.Detections.NoClip then goto continue end
        
        local ped = PlayerPedId()
        local pos = GetEntityCoords(ped)
        
        -- Check if player is underground or in invalid position
        if pos.z < -50.0 then
            SendDetection('NoClip', {
                position = pos,
                reason = 'underground'
            })
        end
        
        -- Check if player is moving through walls
        if not IsPedInAnyVehicle(ped, false) and not IsPedSwimming(ped) then
            local _, groundZ = GetGroundZFor_3dCoord(pos.x, pos.y, pos.z, 0)
            if groundZ == 0 and pos.z > 100.0 then
                SendDetection('NoClip', {
                    position = pos,
                    reason = 'floating'
                })
            end
        end
        
        ::continue::
    end
end)

-- Super jump detection
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(100)
        
        if not IsInitialized or IsWhitelisted() then goto continue end
        if not Config.Detections.SuperJump then goto continue end
        
        local ped = PlayerPedId()
        
        if IsPedJumping(ped) then
            local velocity = GetEntityVelocity(ped)
            local jumpHeight = velocity.z
            
            if jumpHeight > Config.Thresholds.JumpHeight then
                SendDetection('SuperJump', {
                    height = jumpHeight,
                    position = GetEntityCoords(ped)
                })
            end
        end
        
        ::continue::
    end
end)

-- Resource monitoring
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(Config.CheckIntervals.Resources)
        
        if not IsInitialized or IsWhitelisted() then goto continue end
        
        -- Check for suspicious resource starts/stops
        local resources = {}
        for i = 0, 255 do
            local resource = GetResourceByFindIndex(i)
            if resource then
                table.insert(resources, resource)
            end
        end
        
        ::continue::
    end
end)

-- Model monitoring
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(5000)
        
        if not IsInitialized or IsWhitelisted() then goto continue end
        if not Config.Detections.BlacklistedModels then goto continue end
        
        local ped = PlayerPedId()
        local model = GetEntityModel(ped)
        
        for _, blacklistedModel in ipairs(Config.BlacklistedModels) do
            if model == GetHashKey(blacklistedModel) then
                SendDetection('BlacklistedModel', {
                    model = blacklistedModel,
                    hash = model
                })
                -- Change to default model
                SetPlayerModel(PlayerId(), GetHashKey("mp_m_freemode_01"))
                break
            end
        end
        
        ::continue::
    end
end)

-- Injection detection
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(10000)
        
        if not IsInitialized or IsWhitelisted() then goto continue end
        if not Config.Detections.Injection then goto continue end
        
        -- Check for suspicious NUI windows
        local windows = {}
        for i = 0, 255 do
            -- This is a basic check, more sophisticated methods may be needed
            if SetNuiFocus then
                -- Additional injection checks can be added here
            end
        end
        
        ::continue::
    end
end)

-- Prevent common exploits
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        
        if not IsInitialized or IsWhitelisted() then goto continue end
        
        local ped = PlayerPedId()
        
        -- Prevent weapon explosions
        if Config.Detections.WeaponExplosions then
            if IsPedShooting(ped) then
                local weapon = GetSelectedPedWeapon(ped)
                if weapon == GetHashKey('WEAPON_RPG') or weapon == GetHashKey('WEAPON_GRENADELAUNCHER') then
                    SendDetection('WeaponExplosion', {
                        weapon = weapon
                    })
                end
            end
        end
        
        -- Prevent infinite ammo
        if Config.Detections.InfiniteAmmo then
            local ammo = GetAmmoInPedWeapon(ped, GetSelectedPedWeapon(ped))
            if ammo > 9999 then
                SendDetection('InfiniteAmmo', {
                    ammo = ammo,
                    weapon = GetSelectedPedWeapon(ped)
                })
            end
        end
        
        ::continue::
    end
end)

-- Event handlers for suspicious activities
AddEventHandler('explosionEvent', function(sender, ev)
    if not IsInitialized or IsWhitelisted() then return end
    if not Config.Detections.WeaponExplosions then return end
    
    if sender == PlayerId() then
        SendDetection('WeaponExplosion', {
            type = ev.explosionType,
            coords = ev.coords
        })
    end
end)

-- Block resource manipulation attempts
AddEventHandler('onClientResourceStop', function(resourceName)
    if not IsInitialized then return end
    if not Config.Detections.ResourceStop then return end
    
    if resourceName ~= 'anticheat' then
        SendDetection('ResourceStop', {
            resource = resourceName
        })
    end
end)

-- Debug commands (only if debug mode is enabled)
if Config.Debug then
    RegisterCommand('ac_debug', function()
        print("[AntiCheat] Debug Info:")
        print(string.format("Initialized: %s", tostring(IsInitialized)))
        print(string.format("Whitelisted: %s", tostring(IsWhitelisted())))
        print(string.format("Health: %d", GetEntityHealth(PlayerPedId())))
        print(string.format("Armor: %d", GetPedArmour(PlayerPedId())))
        print(string.format("Speed: %.2f km/h", GetEntitySpeed(PlayerPedId()) * 3.6))
    end, false)
end

-- Initialize on resource start
AddEventHandler('onClientResourceStart', function(resourceName)
    if resourceName == GetCurrentResourceName() then
        print("[AntiCheat] Client side initialized")
        TriggerServerEvent('anticheat:playerReady')
    end
end)
