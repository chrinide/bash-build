add_package --build generic http://ftp.gnu.org/gnu/m4/m4-1.4.17.tar.gz

pack_set -s $MAKE_PARALLEL

pack_set --module-requirement build-tools
pack_set --prefix $(pack_get --prefix build-tools)

p_V=$(pack_get --version)
c_V=`m4 --version 2>/dev/null| head -1 | awk '{print $4}'`
[[ -z "${c_V// /}" ]] && c_V=1.1.1
if [[ $(vrs_cmp $c_V $p_V) -eq 1 ]]; then
    pack_set --host-reject "$(get_hostname)"
fi

pack_set --install-query $(pack_get --prefix)/bin/m4

# Install commands that it should run
pack_cmd "./configure" \
	 "--enable-c++" \
	 "--prefix $(pack_get --prefix)"

# Make commands
pack_cmd "make $(get_make_parallel)"
pack_cmd "make install"
