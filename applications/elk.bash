add_package http://garr.dl.sourceforge.net/project/elk/elk-2.2.10.tgz

pack_set -s $IS_MODULE

pack_set --install-query $(pack_get --install-prefix)/bin/elk

pack_set --module-requirement openmpi \
    --module-requirement libxc \
    --module-requirement fftw-3

# Add the lua family
pack_set --module-opt "--lua-family elk"

tmp=
if $(is_c intel) ; then
    tmp="-openmp -mkl=cluster"
elif $(is_c gnu) ; then
    tmp=-fopenmp

else
    doerr elk "Could not determine compiler"
fi

file=make.inc
# Prepare the compilation arch.make
pack_set --command "echo '# Compilation $(pack_get --version) on $(get_c)' > $file"
pack_set --command "sed -i '1 a\
MAKE = make\n\
F90 = $FC\n\
F90_OPTS = $FCFLAGS $tmp \n\
F77 = $F77\n\
F77_OPTS = $FCFLAGS $tmp \n\
AR = $AR \n\
LIB_XC = $(list --LDFLAGS --Wlrpath libxc) -lxc\n\
LIB_FFT = $(list --LDFLAGS --Wlrpath fftw-3) -lfftw3\n\
' $file"

tmp=
# Check for Intel MKL or not
if $(is_c intel) ; then
    pack_set --command "sed -i '1 a\
LIB_LPK = -mkl=cluster\n\
' $file"

elif $(is_c gnu) ; then
    if [ $(pack_installed atlas) -eq 1 ] ; then
	pack_set --module-requirement atlas
	tmp="-llapack_atlas -lf77blas -lcblas -latlas"
    else
	pack_set --module-requirement blas --module-requirement lapack
	tmp="-llapack -lblas"
    fi
    pack_set --command "sed -i '1 a\
LIB_LPK = $(list --LDFLAGS --Wlrpath $(pack_get --module-paths-requirement)) $tmp\n\
' $file"

else
    doerr "$(pack_get --package)" "Could not recognize the compiler: $(get_c)"

fi

# Create the correct file for the interface to FFTW
file=src/zfftifc.f90
pack_set --command "echo '! FFTW routine' > $file"
pack_set --command "sed -i 'a\
subroutine zfftifc(nd,n,sgn,z)\n\
implicit none\n\
integer, intent(in) :: nd, n(nd), sgn\n\
complex(8), intent(inout) :: z(*)\n\
integer, parameter :: FFTW_ESTIMATE=64\n\
integer i,p\n\
integer(8) plan\n\
real(8) t1\n\
!\$OMP CRITICAL\n\
call dfftw_plan_dft(plan,nd,n,z,z,sgn,FFTW_ESTIMATE)\n\
!\$OMP END CRITICAL\n\
call dfftw_execute(plan)\n\
!\$OMP CRITICAL\n\
call dfftw_destroy_plan(plan)\n\
!\$OMP END CRITICAL\n\
if (sgn.eq.-1) then\n\
  p=1\n\
  do i=1,nd\n\
    p=p*n(i)\n\
  end do\n\
  t1=1.d0/dble(p)\n\
  call zdscal(p,t1,z,1)\n\
end if\n\
end subroutine\n\
' $file"

pack_set --command "make $(get_make_parallel)"

pack_set --command "mkdir -p $(pack_get --install-prefix)/bin"
pack_set --command "cd src"
pack_set --command "cp protex elk $(pack_get --install-prefix)/bin/"
pack_set --command "cd ../utilities"
pack_set --command "cp blocks2columns/blocks2columns.py $(pack_get --install-prefix)/bin/"
pack_set --command "cp wien2k-elk/se.pl $(pack_get --install-prefix)/bin/"
pack_set --command "chmod a+x $(pack_get --install-prefix)/bin/*"

pack_install

create_module \
    --module-path $(build_get --module-path)-npa-apps \
    -n "Nick Papior Andersen's script for loading $(pack_get --package): $(get_c)" \
    -v $(pack_get --version) \
    -M $(pack_get --alias).$(pack_get --version)/$(get_c) \
    -P "/directory/should/not/exist" \
    $(list --prefix '-L ' $(pack_get --module-requirement)) \
    -L $(pack_get --alias)