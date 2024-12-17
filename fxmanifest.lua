fx_version 'cerulean'
game 'gta5'

author 'Djonza'
description 'FiveM report Panel'
version '1.0.0'
lua54 'yes'

shared_scripts {
    'config.lua',
    '@ox_lib/init.lua',
    '@es_extended/imports.lua',
}


client_scripts {
    'client.lua',
}

server_scripts {
    'server.lua',
    '@oxmysql/lib/MySQL.lua'
}

ui_page {
 'nui/report.html',
}

files {
    'nui/report.html',
    'nui/report.css',
    'nui/report.js',
    'locales/*.json'
}
