[ "x${pV:0:1}" == "x3" ] && return 0

add_package https://pypi.python.org/packages/source/m/mock/mock-1.0.1.tar.gz

pack_set --module-requirement $(get_parent)
pack_set --install-query $(pack_get --prefix $(get_parent))/lib/python$pV/site-packages/mock-$(pack_get --version)-py$pV.egg

pack_set --command "$(get_parent_exec) setup.py install" \
    --command-flag "--prefix=$(pack_get --prefix $(get_parent))"