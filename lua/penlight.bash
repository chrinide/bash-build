add_package --build generic \
    --directory Penlight-1.3.1 \
    https://github.com/stevedonovan/Penlight/archive/1.3.1.tar.gz

pack_set --module-requirement lua

pack_set --install-query $(pack_get --install-prefix lua)/lib/lua/$lua_V/pl

pack_set --command "cd lua"
pack_set --command "cp -rf pl $(pack_get --install-prefix lua)/lib/lua/$lua_V/"