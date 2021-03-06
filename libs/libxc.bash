v=2.2.2
add_package http://www.tddft.org/programs/octopus/download/libxc/libxc-$v.tar.gz

pack_set -s $IS_MODULE -s $BUILD_DIR

pack_set --install-query $(pack_get --LD)/libxc.a

pack_cmd "../configure" \
	 "--enable-shared" \
	 "--prefix=$(pack_get --prefix)"

pack_cmd "make $(get_make_parallel)"
pack_cmd "make check > tmp.test 2>&1"
pack_cmd "make install"
pack_set_mv_test tmp.test

