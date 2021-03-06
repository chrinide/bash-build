# MUMPS 4.10.0 only works with 5.1.12b, MUMPS 5 works with >=6.0.1
for v in 6.0.4 ; do
add_package --package scotch --alias scotch --version $v --directory scotch_6.0.3 \
    http://gforge.inria.fr/frs/download.php/file/34099/scotch_$v.tar.gz

pack_set -s $IS_MODULE

pack_set --install-query $(pack_get --LD)/libscotch.a

pack_set --module-requirement zlib --module-requirement mpi

pack_set --lib "-lscotch -lscotcherr -lscotcherrexit"
pack_set --lib[pt] "-lptscotch -lptscotcherr -lptscotcherrexit"


if [[ $(pack_installed bison) -eq 1 ]]; then
    pack_cmd "module load $(pack_get --module-name-requirement bison) $(pack_get --module-name bison)"
fi
if [[ $(pack_installed flex) -eq 1 ]]; then
    pack_cmd "module load $(pack_get --module-name-requirement flex) $(pack_get --module-name flex)"
fi

# Move to source
pack_cmd "cd src"

file=Makefile.inc
pack_cmd "echo '# Makefile for easy installation ' > $file"

if $(is_c intel) ; then

    pack_cmd "sed -i '1 a\
CFLAGS = -restrict\n' $file"
    
elif $(is_c gnu) ; then
    
    pack_cmd "sed -i '1 a\
CFLAGS = -Drestrict=__restrict\n' $file"
    
fi

pack_cmd "sed -i '$ a\
EXE = \n\
LIB = .a \n\
OBJ = .o \n\
MAKE = make \n\
AR = $AR \n\
ARFLAGS = -ruv \n\
CAT = cat \n\
CCS = $CC \n\
CCP = $MPICC \n\
CCD = $CC $(list --INCDIRS mpi) \n\
CFLAGS += $CFLAGS -DCOMMON_FILE_COMPRESS_GZ -DCOMMON_RANDOM_FIXED_SEED -DSCOTCH_RENAME -DIDXSIZE64 \n\
CFLAGS += -DCOMMON_PTHREAD -DSCOTCH_PTHREAD\n\
CLIBFLAGS = \n\
LDFLAGS = $(list --LD-rp +mpi) -lz -lm -lrt -lpthread \n\
CP = cp \n\
LEX = flex -Pscotchyy -olex.yy.c \n\
LN = ln \n\
MKDIR = mkdir \n\
RANLIB = ranlib \n\
YACC = bison -pscotchyy -y -b y \n\
\n\
prefix = $(pack_get --prefix)\n\
\n' $file"

# the makefile does not create the directory...
pack_cmd "mkdir -p $(pack_get --prefix)"

# Make commands
pack_cmd "make $(get_make_parallel) ptscotch"
if [[ $(vrs_cmp $v 6.0.0) -lt 0 ]]; then
    pack_cmd "make $(get_make_parallel) ptesmumps"
fi
pack_cmd "make install"
# this check waits for a key-press????
#pack_cmd "make ptcheck > tmp.test 2>&1"
#pack_set_mv_test tmp.test ptmp.test
pack_cmd "make clean"

# Remove threads
pack_cmd "sed -i -e 's/-DSCOTCH_PTHREAD//gi' $file"
pack_cmd "sed -i -e 's/-DCOMMON_PTHREAD//gi' $file"
pack_cmd "sed -i -e 's/-lpthread//gi' $file"
pack_cmd "make $(get_make_parallel) scotch"
if [[ $(vrs_cmp $v 6.0.0) -lt 0 ]]; then
    pack_cmd "make $(get_make_parallel) esmumps"
fi
#pack_cmd "make check > tmp.test 2>&1"
pack_cmd "make install"
#pack_set_mv_test tmp.test

if [[ $(pack_installed flex) -eq 1 ]] ; then
    pack_cmd "module unload $(pack_get --module-name flex) $(pack_get --module-name-requirement flex)"
fi
if [[ $(pack_installed bison) -eq 1 ]] ; then
    pack_cmd "module unload $(pack_get --module-name bison) $(pack_get --module-name-requirement bison)"
fi

done
