v=0.11.0
add_package https://pypi.python.org/packages/source/n/numba/numba-$v.tar.gz

pack_set -s $IS_MODULE

pack_set --module-requirement $(get_parent)
pack_set --module-requirement cython
pack_set --module-requirement cffi
pack_set --module-requirement llvmpy
pack_set --module-requirement llvmmath
pack_set --module-requirement numpy[1.7.2]

pack_set --install-query $(pack_get --install-prefix)/bin/numba

pack_set --command "$(get_parent_exec) setup.py install" \
    --command-flag "--prefix=$(pack_get --install-prefix)"

add_package --package numba-test fake
pack_set --install-query $(pack_get --install-prefix numba)/test.output
pack_set --module-requirement numba
pack_set --command "$(get_parent_exec) -c 'import numba; numba.test()' > tmp.test 2>&1"
pack_set --command "mv tmp.test $(pack_get --install-query)"
