if $(is_host surt) ; then
    echo "Will make link to local installation."
elif $(is_host thul) ; then
    echo "Will make link to local installation."
else
    source libs/openmpi.bash
    return 0
fi

# Figure out the module we require to use...

# Determine the name of the local module:
if $(is_host surt) ; then
    if $(is_c intel) ; then
        mod=openmpi/1.6.3-sl230s-tm-intel-2013.1.117-1
    elif $(is_c gnu) ; then
        mod=openmpi/1.6.3-sl230s-tm-gfortran-1
    else
        doerr 1 "Could not determine compiler for OpenMPI on niflheim"
    fi
elif $(is_host thul) ; then
    if $(is_c intel) ; then
        mod=openmpi/1.3.3-1.el5.fys.ifort.11.1
    elif $(is_c gnu) ; then
        mod=openmpi/1.3.3-1.el5.fys.gfortran43.4.3.2
    else
        doerr 1 "Could not determine compiler for OpenMPI on niflheim"
    fi
fi

# Enable the reading of the "hidden" package...
add_hidden_package $mod


# Install the easiest first... OpenMPI
add_package here/openmpi-hpc.tar.gz

pack_set --package openmpi
pack_set --alias openmpi
pack_set --version hpc
pack_set --installed 1
pack_set --module-name $(pack_get --alias)/$(pack_get --version)/$(get_c)


module load $(get_default_modules)
module load $mod
tmp=$(which mpif90)
pack_set --install-prefix ${tmp//\/bin*/}
module unload $mod
module unload $(get_default_modules)

create_module \
    -n "\"Nick Papior Andersen's script for loading $(pack_get --package): $(get_c)\"" \
    -v $(pack_get --version) \
    -M $(pack_get --alias)/$(pack_get --version)/$(get_c) \
    -P "/directory/should/not/exist" \
    $(list --prefix '-L ' $(get_default_modules)) \
    -L $mod
