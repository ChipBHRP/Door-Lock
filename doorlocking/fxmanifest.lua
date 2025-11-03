fx_version 'cerulean'
games { 'gta5' }

author 'Chip'
description 'Door Locking System With Forced Entry'

shared_script '@ox_lib/init.lua' 

client_scripts {
    'config.lua',
    'client.lua'
}


server_script 'server.lua'
