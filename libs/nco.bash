v=4.3.2
add_package http://nco.sourceforge.net/src/nco-$v.tar.gz

pack_set -s $BUILD_DIR -s $MAKE_PARALLEL -s $IS_MODULE

pack_set --install-query $(pack_get --install-prefix)/bin/ncks

# Add requirments when creating the module
# udunits depend on NetCDF
pack_set --module-requirement gsl \
    --module-requirement udunits

# Install commands that it should run
pack_set \
    --command "../configure" \
    --command-flag "LDFLAGS='$(list --Wlrpath $(pack_get --module-requirement))'" \
    --command-flag "--prefix=$(pack_get --install-prefix)" \
    --command-flag "--enable-netcdf-4" \
    --command-flag "--enable-udunits2" \
    --command-flag "--enable-gsl"

# Make commands
pack_set --command "make $(get_make_parallel)"
pack_set --command "make install"