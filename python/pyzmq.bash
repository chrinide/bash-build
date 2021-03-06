# apt-get libzmq-dev
add_package https://github.com/zeromq/pyzmq/releases/download/v14.1.1/pyzmq-14.1.1.tar.gz

pack_set --install-query $(pack_get --prefix $(get_parent))/lib/python$pV/site-packages/$(pack_get --package)-$(pack_get --version)-py$pV.egg-info

pack_cmd "$(get_parent_exec) setup.py install" \
    "--prefix=$(pack_get --prefix $(get_parent))"
