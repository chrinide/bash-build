v=5-3-1

for c in gfortran ifort open64 pgi ; do
if [ "$c" == "gfortran" ]; then
    if ! $(is_c gnu) ; then
	continue
    fi
elif [ "$c" == "ifort" ]; then
    if ! $(is_c intel) ; then
	continue
    fi
fi
# we don't need the pgi compiler on nilfheim
if $(is_host surt muspel slid) ; then
    [ "$c" == "pgi" ] && continue
fi
# On my machines I will only ever use gfortran and ifort (for now...)
if $(is_host zero ntch) ; then
    [ "$c" == "open64" ] && continue
    [ "$c" == "pgi" ] && continue
fi
add_package --build vendor \
    --version ${v//-/.} \
    --package acml \
    --alias acml-install \
    --directory ./ \
    http://www.student.dtu.dk/~nicpa/packages/acml-$v-$c-64bit.tgz

pack_set --install-query $(pack_get --install-prefix)/${c}64

pack_set --command "./install-acml-$v-$c-64bit.sh -accept -installdir=$(pack_get --install-prefix)"

pack_set --command "rm install-acml-$v-$c-64bit.sh contents-acml-$v-$c-64bit.tgz ACML-EULA.txt README.64-bit"

pack_install

# We need to create all the different modules...
for directive in nothing fma4 ; do
[ "$directive" == "nothing" ] && directive=""
for mp in nothing mp ; do
[ "$mp" == "nothing" ] && mp=""

tmp=${c//gfortran/gnu}
tmp=${tmp//ifort/intel}
[ -n "$directive" ] && tmp=${tmp}-$directive
[ -n "$mp" ] && tmp=${tmp}-$mp

add_package --build vendor \
    --version ${v//-/.} \
    --alias acml-$tmp \
    --package acml \
    --directory ./ \
    acml.local

pack_set -s $IS_MODULE

pack_set --install-prefix $(pack_get --install-prefix acml-install)

# Add ./util dir to path
pack_set --module-opt "--prepend-ENV PATH=$(pack_get --install-prefix)/util"

# Create custom ACML_DIR env-variable
tmp=${c}64
[ -n "$directive" ] && tmp=${tmp}_$directive
[ -n "$mp" ] && tmp=${tmp}_$mp
pack_set --install-prefix $(pack_get --install-prefix acml-install)/$tmp

pack_set --module-opt "--set-ENV ACML_DIR=$(pack_get --install-prefix)"

pack_set --lua-family acml

pack_set --install-query /directory/does/not/exist
tmp=${c//gfortran/gnu}
tmp=${tmp//ifort/intel}
[ ! -z "$directive" ] && tmp="${tmp}-$directive"
[ ! -z "$mp" ] && tmp="${tmp}-$mp"
pack_set --module-name acml/${v//-/.}/$tmp

# As this is only module-installations we might as well do it immediately...
pack_install

done # mp
done # directive
done # compiler
