add_package http://www.student.dtu.dk/~nicpa/packages/gulp_4.0.tar.gz

pack_set -s $IS_MODULE

pack_set --host-reject ntch

pack_set --install-query $(pack_get --install-prefix)/bin/gulp

pack_set --directory $(pack_get --directory)/Src

pack_set --module-requirement openmpi

tmp=$(get_c)
if [ "${tmp:0:5}" == "intel" ]; then
    pack_set --command "sed -i '1 a\
LIBS = -L$MKL_PATH/lib/ -Wl,-rpath=$MKL_PATH/lib -lmkl_blas95_lp64 -lmkl_lapack95_lp64' Makefile"
    
elif [ "${tmp:0:3}" == "gnu" ]; then
    pack_set --module-requirement atlas
    pack_set --command "sed -i '1 a\
LIBS = $(list --LDFLAGS --Wlrpath atlas) -llapack_atlas -lf77blas -lcblas -latlas' Makefile"

else
    doerr $(pack_get --package) "Could not determine compiler: $(get_c)"

fi

pack_set --command "sed -i '1 a\
DEFS=-DMPI
OPT = \n\
OPT1 = $CFLAGS\n\
OPT2 = -ffloat-store\n\
BAGGER = \n\
RUNF90 = $FC\n\
RUNCC = $CC\n\
FFLAGS = -I.. $FCFLAGS $(list --INCDIRS --LDFLAGS --Wlrpath $(pack_get --module-requirement))\n\
BLAS = \n\
LAPACK = \n\
CFLAGS = -I.. $CFLAGS $(list --INCDIRS --LDFLAGS --Wlrpath $(pack_get --module-requirement))\n\
ETIME = \n\
GULPENV = \n\
CDABS = cdabs.o\n\
ARCHIVE = $AR rcv\n\
RANLIB = ranlib\n' Makefile"

# Make commands
pack_set --command "make $(get_make_parallel) gulp"
pack_set --command "make $(get_make_parallel) lib"

# Install the package
pack_set --command "mkdir -p $(pack_get --install-prefix)/bin/"
pack_set --command "mkdir -p $(pack_get --install-prefix)/lib/"
pack_set --command "cp gulp $(pack_get --install-prefix)/bin/"
pack_set --command "cp ../libgulp.a $(pack_get --install-prefix)/lib/"

pack_install

create_module \
    --module-path $install_path/modules-npa-apps \
    -n "\"Nick Papior Andersen's script for loading $(pack_get --package): $(get_c)\"" \
    -v $(pack_get --version) \
    -M $(pack_get --alias).$(pack_get --version).$(get_c) \
    -P "/directory/should/not/exist" \
    $(list --prefix '-L ' --loop-cmd 'pack_get --module-name' $(pack_get --module-requirement)) \
    -L $(pack_get --module-name)