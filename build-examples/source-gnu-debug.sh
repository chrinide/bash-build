set_c gnu-6.4.0

AR=gcc-ar
RANLIB=gcc-ranlib
CC=gcc
CXX=g++
#CPP="gcc -E"
#CXXCPP="g++ -E"
F77=gfortran
F90=gfortran
FC=gfortran
common_flags="-m64 -fPIC -fbounds-check -g -fbacktrace"
# Possibly add:
#  -fcheck-pointer-bounds -mmpx
# for pointer checks
CFLAGS="$common_flags"
CXXFLAGS="$common_flags"

FCFLAGS="$common_flags -fno-second-underscore"
FFLAGS="$common_flags -fno-second-underscore"

FLAG_OMP="-fopenmp"
MPICC=mpicc
#MPICPP="mpicc -E"
MPICXX=mpicxx
#MPICXXCPP="mpicxx -E"
MPIFC=mpifort
MPIF77=mpifort
MPIF90=mpifort

LDFLAGS=

export FLAG_OMP
export AR
export RANLIB
export CC
export CXX
export CPP
export CXXCPP
export FC
export F77
export F90
export LDFLAGS
export CFLAGS
export FCFLAGS
export FFLAGS
export MPICC
export MPIFC
export MPIF77
export MPIF90