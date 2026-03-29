-- FiveM AntiCheat Manifest
-- Created by D

fx_version 'cerulean'
game 'gta5'

author 'D'
description 'Advanced FiveM AntiCheat System with Discord Logging'
version '1.0.0'

-- Configuration
shared_script 'config.lua'

-- Server scripts
server_script 'server.lua'

-- Client scripts
client_script 'client.lua'

-- Dependencies (if any)
-- dependencies {
--     'es_extended', -- Uncomment if using ESX
-- }

-- Data files (if any)
-- data_file 'animation_meta' 'data/animation.meta'

-- Export functions
exports {
    'GetConfig'
}

-- Server exports
server_exports {
    'GetConfig'
}

-- Additional metadata
lua54 'yes'

-- Resource metadata
dependency 'nativeui' -- Optional: for UI elements (if added later)
