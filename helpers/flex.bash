add_package --build generic http://prdownloads.sourceforge.net/flex/flex-2.5.37.tar.gz

pack_set -s $MAKE_PARALLEL -s $IS_MODULE

pack_set --install-query $(pack_get --install-prefix)/bin/flex

tmp="$(which flex 2>/dev/null)"
[ "${tmp:0:1}" == "/" ] && pack_set --host-reject $(get_hostname)

# Install commands that it should run
pack_set --command "./configure" \
    --command-flag "--prefix $(pack_get --install-prefix)"

# Make commands
pack_set --command "make $(get_make_parallel)"
pack_set --command "make" \
    --command-flag "install"

pack_install