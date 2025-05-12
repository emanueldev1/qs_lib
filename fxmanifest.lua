fx_version 'cerulean'
use_experimental_fxv2_oal 'yes'
lua54 'yes'
games { 'rdr3', 'gta5' }
rdr3_warning 'I understand that this is an early RedM build, and I accept that my resources may not work once the final RedM version is released.'

name 'QuasarLib'
author 'Quasar Development Team'
version '0.0.0'
license 'LGPL-3.0-or-later'
repository 'https://github.com/emanueldev1/qs_lib'
description 'A comprehensive utility library providing reusable functions for seamless integration across multiple resources.'

ui_page 'web/build/index.html'

files {
   'init.lua',
   'src/settings.lua',
   'src/autodetect.lua',
   'modules/client/*.lua',
   'modules/shared/*.lua',
   'bridge/**/client.lua',
   'bridge/**/server.lua',
   'bridge/**/shared.lua',
   'web/build/index.html',
   'web/build/**/*',
   'locales/*.json',
}

shared_script 'src/init.lua'

shared_scripts {
   'src/**/shared.lua',
}

client_scripts {
   -- LUA FILES
   'src/**/client.lua',
   'src/**/client/*.lua'
}

server_scripts {
   -- LUA FILES
   'modules/server/callback.lua',
   'modules/server/getFilesInDirectory.lua',
   'src/**/server.lua',
   'src/**/server/*.lua',
}

dependencies {
   '/server:7290',
   '/onesync',
}


provide 'ox_lib'


-- letters to test the release process.
