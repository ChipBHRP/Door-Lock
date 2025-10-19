fx_version 'cerulean'
games { 'gta5' }

Author 'Chip'

shared_script '@ox_lib/init.lua' 

client_scripts {
    'config.lua',
    'client.lua'
}

server_script 'server.lua'