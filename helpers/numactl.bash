add_package --build generic \
    ftp://oss.sgi.com/www/projects/libnuma/download/numactl-2.0.9.tar.gz

pack_set -s $MAKE_PARALLEL -s $IS_MODULE

pack_set --install-query $(pack_get --install-prefix)/bin/numactl

# Set the suffix
pack_set --library-suffix lib64

# Make commands
pack_set --command "make OPT_CFLAGS='$CFLAGS' LDFLAGS='$(list --LDFLAGS --Wlrpath numactl)' PREFIX=$(pack_get --install-prefix)"
pack_set --command "make install PREFIX=$(pack_get --install-prefix)"

pack_install