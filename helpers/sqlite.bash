v=3.14.2
dv=3140200
add_package --package sqlite --build generic --version $v \
	    http://www.sqlite.org/2016/sqlite-autoconf-$dv.tar.gz

pack_set -s $MAKE_PARALLEL -s $IS_MODULE -s $BUILD_DIR

pack_set --install-query $(pack_get --prefix)/bin/sqlite3

# Install commands that it should run
pack_cmd "../configure" \
	 "--prefix $(pack_get --prefix)"

# Make commands
pack_cmd "make $(get_make_parallel)"
pack_cmd "make install"
