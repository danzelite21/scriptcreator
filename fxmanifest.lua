fx_version 'cerulean'
game 'gta5'

author 'ScriptCreator'
description 'FiveM admin creator script dengan NPC, Blip, Marker, Item, Image, audit logging, dan export'
version '1.0.0'

shared_script 'config.lua'
server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/main.lua'
}
client_script 'client/main.lua'

ui_page 'html/index.html'
files {
    'html/index.html',
    'html/style.css',
    'html/script.js'
}

dependencies {
    'oxmysql',
    'ox_inventory'
}
