# This file should be sourced and used to compile the tools for compiling 
# different libraries.

# Set options
set -o hashall

# Skipping unicode char's might help speed
export LC_ALL=C

if [ ${BASH_VERSION%%.*} -lt 4 ]; then
    doerr "$BASH_VERSION" "Installation requires to use BASH >= 4.x.x"
fi

_DEBUG_COUNTER=0
function debug { echo "Debug: ${_DEBUG_COUNTER} $@" ; let _DEBUG_COUNTER++ ; }

_cwd=$(pwd)
_ERROR_FILE=$_cwd/ERROR
# Clean the error file
rm -f $_ERROR_FILE

# Make an error and exit
function doerr {
    local prefix="ERROR: "
    for ln in "$@" ; do
        echo "${prefix}${ln}" >> $_ERROR_FILE
        echo "${prefix}${ln}"
        prefix="       "
    done ; exit 1
}

source src/globals.bash
# Whether we should create TCL or LUA module files
_module_format='TCL'

_crt_version=0

_parent_package=""
# The parent package (for instance Python)
function set_parent {       _parent_package=$1 ; }
function clear_parent {     _parent_package="" ; }
function get_parent { _ps "$_parent_package" ; }

_parent_exec=""
# The parent package (for instance Python)
function set_parent_exec {       _parent_exec=$1 ; }
function get_parent_exec { _ps "$_parent_exec" ; }

# Create a list of packages that _only_ will
# be installed
# This can be handy to create custom builds which
# can test certain parts.
declare -A _pack_only
function pack_only {
    [ $DEBUG -ne 0 ] && do_debug --enter pack_only
    local tmp
    while [ $# -gt 0 ]; do
	local opt=$(trim_em $1)
	case $opt in
	    -file)
		shift
		# We will add all packages found in the file
		local line
		# parse file
		while read line
		do
		    [ "x${line:0:1}" == "x#" ] && continue
		    _pack_only[$line]=1
		done < $1
		shift
		;;
	    *)
		_pack_only[$opt]=1
		shift
		;;
	esac
    done
    [ $DEBUG -ne 0 ] && do_debug --return pack_only
}

# Add any auxillary commands
source src/auxiliary.bash

# Add the compiler stuff 
source src/compiler.bash

# Add host information
source src/host.bash

# The place of all the archives
_archives="$_cwd/.archives"
function pwd_archives { _ps "$_archives" ; }

_install_prefix_no_path="HIDDEN"

source src/build.bash
source src/package.bash
source src/install.bash
source src/module.bash


# Function for editing environment variables
# Mainly used for receiving and appending to variables
function edit_env {
    local opt=$(trim_em $1) # Save the option passed
    shift
    local echo_env=0
    local append="" ; local prepend=""
    case $opt in
	-g|-get)           echo_env=1 ;;
	-p|-prepend)       prepend="$1" ; shift ;;
	-a|-append)        append="$1" ; shift ;;
	*)
	    doerr $1 "No option for edit_env found for $1" ;;
    esac
    local env=$1
    shift
    [ "$echo_env" -ne "0" ] && _ps "${!env}" && return 0
    # Process what is requested
    [ ! -z "$append" ] && export ${!env}="${!env}$append"
    [ ! -z "$prepend" ] && eval "export $env='$prepend${!env}'"
}


# Has setting returns 1 for success and 0 for fail
#   $1 : <setting>
#   $2 : <index|name of archive>
function has_setting {
    local ss="" ; local s="$1" ; shift
    local -a sets=()
    [ $# -gt 0 ] && ss="$1" && shift
    IFS="$_LIST_SEP" read -ra sets <<< "$(pack_get -s $ss)"
    for ss in "${sets[@]}" ; do
	[ "x$s" == "x$ss" ] && return 0
    done
    return 1
}

# Returns a list of the choices
#   $1 : name according to the choic
#   $2 : this package
function choice {
    local ss="" ; local s="$1" ; shift
    local -a sets=()
    [ $# -gt 0 ] && ss="$1" && shift
    local len=${#s}
    IFS="$_LIST_SEP" read -ra sets <<< "$(pack_get -s $ss)"
    for ss in "${sets[@]}" ; do
	if [ "x$s" == "x${ss:0:$len}" ]; then
	    IFS="|" read -ra sets <<< "${ss:$len}"
	    for ss in "${sets[@]}" ; do
		_ps " $ss"
	    done
	    return 0
	fi
    done
    return 1
}
    
# Returns the -j <procs> flag for the make command
# If the MAKE_PARALLEL setting has been enabled.
#   $1 : <index of archive>
function get_make_parallel {
    if $(has_setting $MAKE_PARALLEL $1) ; then
	_ps "-j $_n_procs"
    else
	_ps ""
    fi
}

#################################################
#################################################
###########     Helper functions     ############

# Return the latest index, or the provided one, if any
function _get_true_index {
    if [ $# -eq 0 ]; then
	_ps "$_N_archives"
    else
	_ps "$1"
    fi
}

# Make an error and exit
function exit_on_error {
    if [ $1 -ne 0 ]; then
	shift
	doerr "$@"
    fi
}

function pack_crt_list {
    [ $PACK_LIST -eq 0 ] && return
    # It will only take one argument...
    local pack=$_N_archives
    [ $# -gt 0 ] && pack=$1
    local build=$(pack_get --build $pack)
    build=$(build_get --build-path $build)
    local mr=$(pack_get --module-requirement $pack)
    if [ ! -z "$mr" ]; then
	{
	    echo "# Used packages"
	    for p in $mr ; do
		echo "$p"
	    done
	    echo "$(pack_get --alias $pack)"
	} > $build/$(pack_get --alias $pack)-$(pack_get --version $pack).list
    fi
}


# Update the package version number by looking at the date in the file
function pack_set_file_version {
    local idx=$_N_archives
    [ $# -gt 0 ] && idx=$(get_index $1)
    # Download the archive
    dwn_file $idx $(build_get --archive-path)
    local v="$(get_file_time %g-%j $(build_get --archive-path)/$(pack_get --archive $idx))"
    pack_set --version "$v"
     # Default the module name to this:
    local b_name="$(pack_get --build $idx)"
    local tmp="$(build_get --build-module-path[$b_name])"
    tmp=$(pack_list -lf "-X -p /" $tmp)
    tmp=${tmp%/}
    tmp=${tmp#/}
    pack_set --module-name $tmp $idx
    local tmp="$(build_get --build-installation-path[$b_name])"
    pack_set --prefix $(build_get --installation-path[$b_name])/$(pack_list -lf "-X -s /" $tmp) $idx
    tmp=$(pack_get --prefix $idx)
    pack_set --prefix ${tmp%/} $idx

}


function do_debug {
    local n=""
    while [ $# -gt 1 ]; do
	local opt=$(trim_em $1) ; shift
	case $opt in
	    -msg) n="$1" ; shift ;;
	    -enter) n="enter routine: $1" ; shift ;;
	    -return) n="return from routine: $1" ; shift ;;
	esac
    done
    echo "$n" >> DEBUG
}
