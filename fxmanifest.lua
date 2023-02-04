fx_version 'cerulean'
games { 'rdr3', 'gta5' }
lua54 'yes'

dependencies {
  'meta_libs',
} 

shared_script '@es_extended/imports.lua'

client_scripts {
  'config.lua',
  'utils.lua',
  'client/main.lua',
}

server_scripts {
  '@mysql-async/lib/MySQL.lua',
  'config.lua',
  'credentials.lua',
  'utils.lua',
  'server/main.lua',
}