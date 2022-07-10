fx_version "adamant"

games { 'gta5'}
lua54 'yes'
use_fxv2_oal 'yes'

-- data_file 'TRAINCONFIGS_FILE' 'data/trains.xml'

-- files {
-- 	'data/trains.xml',
-- }

client_scripts {
	'configs/clientConfig.lua',
    'client/*.lua'
}

server_scripts {
	'configs/serverConfig.lua',
    'server/*.lua'
}

dependencies {
    "plouffe_lib"
}