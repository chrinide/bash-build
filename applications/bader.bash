add_package --version 0.28a \
    http://theory.cm.utexas.edu/henkelman/code/bader/download/bader.tar.gz

pack_set -s $MAKE_PARALLEL -s $IS_MODULE

pack_set --install-query $(pack_get --install-prefix)/bin/bader

file=Makefile
pack_set --command "echo '.SUFFIXES: .f90' > $file"

pack_set --command "sed -i '1 a\
FC = $FC \n\
FFLAGS = ${FCFLAGS//-O3/-O2} \n\
LINK = \n\
OBJS = kind_mod.o matrix_mod.o ions_mod.o options_mod.o charge_mod.o \
chgcar_mod.o cube_mod.o io_mod.o bader_mod.o voronoi_mod.o multipole_mod.o main.o \n\
%.o %.mod: %.f90\n\
\t\$(FC) \$(FFLAGS) -c \$\*.f90\n\
bader: \$(OBJS)\n\
\t\$(FC) \$(LINK) -o bader \$(OBJS)' $file"

# Make commands
pack_set --command "make bader"
pack_set --command "mkdir -p $(pack_get --install-prefix)/bin/"
pack_set --command "cp bader $(pack_get --install-prefix)/bin/"

pack_install


create_module \
    --module-path $(build_get --module-path)-npa-apps \
    -n "Nick Papior Andersen's script for loading $(pack_get --package): $(get_c)" \
    -v $(pack_get --version) \
    -M $(pack_get --alias).$(pack_get --version)/$(get_c) \
    -P "/directory/should/not/exist" \
    $(list --prefix '-L ' $(pack_get --module-requirement)) \
    -L $(pack_get --alias) 
