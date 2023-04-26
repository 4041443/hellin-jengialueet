resource_manifest_version '44febabe-d386-4d18-afbe-5e627f4af937'

description 'ESX hellcity jengialueet leaked by 1443'

version '1.0.1'

client_scripts {
	'@es_extended/locale.lua',
	'locales/fi.lua',
	'config.lua',
	'client/cl_jengialueet.lua'
}

server_scripts {
	'@oxmysql/lib/MySQL.lua',
	'@es_extended/locale.lua',
	'locales/fi.lua',
	'config.lua',
	'server/sv_jengialueet.lua'
}
