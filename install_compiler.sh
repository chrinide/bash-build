
# We here contain any information that could be relevant for compiler setups

_c=""
# Instalation path
function set_c {          _c=$1 ; }
function get_c { echo -n $_c ; }

# Check the compiler...
# Takes one argument:
# #1 : the compiler string to search from the beginning of the compiler-name...
function is_c {
    local check="$1"
    local l="${#check}"
    if [ "x${_c:0:$l}" == "x$check" ]; then
	return 0
    fi
    return 1
}

# Local variables for different optimization levels of the compiler
declare -a _c_fO
declare -a _c_cO

# Sets the compiler optimization levels for the C and F compiler
# It will allow 10 levels (to comply with more differences in compilations)
# 
# Example:
#  set_flags 1 -xHost -O3 ...
#  set_flags 2 -xHost -O3 -opt-prefetch ...
function set_flags {
    set_c_flags $@
    set_f_flags $@
}
# This will only set the C FLAGS
function set_c_flags {
    local idx=$1 ; shift
    _c_cO[$idx]="$@"
    [ $idx -ge 10 ] && return 0
    for i in `seq $((idx+1)) 10` ; do
	if [ "x${_c_cO[$i]}" == "x" ]; then
	    set_c_flags $i $@
	fi
    done
}
# This will only set the Fortran FLAGS
function set_f_flags {
    local idx=$1 ; shift
    _c_fO[$idx]="$@"
    [ $idx -ge 10 ] && return 0
    for i in `seq $((idx+1)) 10` ; do
	if [ "x${_c_fO[$i]}" == "x" ]; then
	    set_f_flags $i $@
	fi
    done
}

# Updates the corresponding environment variable with 
# the optimization level
    