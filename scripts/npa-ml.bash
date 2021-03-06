script=$(tmp_file)
cat <<EOF > $script
#!/bin/bash

# This creates a shorthand for "module"

function ml {
    local args="" opt=load
    if [ \$# -gt 0 ]; then
        case \$1 in
            load|add|rm|unload|swap|switch|purge|refresh|update)
                opt=\$1 ; shift ;;
            show|display|help|clear)
                opt=\$1 ; shift ;;
            av|avail)
                opt=avail ; shift ;;
        esac
    else
        opt=list
    fi
    module \$opt \$@
}

# Returns a list of prereqs so an easy load
# is enabled
# For instance:
#  module load \`ml_prereq numpy\`
function ml_prereq {
    module show \$@ 2>&1 | grep prereq | sed -e "s:prereq::g;s:[[:space:]]::g" | tr "\n" " "
    printf "\n"
}

EOF

pack_cmd "mv $script $(pack_get --prefix)/source/ml.function"


script=$(tmp_file)
cat <<EOF > $script
#!/bin/bash

# This creates the autocompletion for "ml"

source \$NPA_SOURCE/ml.function

function _ml {
    local cur="\$2"
    COMPREPLY=( \$(compgen -W "\$(_module_not_yet_loaded)" -- "\$cur"))
}
complete -F _ml ml

EOF

pack_cmd "mv $script $(pack_get --prefix)/source/ml.bashrc"

script=$(tmp_file)
cat <<EOF > $script
#!/bin/zsh

# This creates the autocompletion for "ml"

source \$NPA_SOURCE/ml.function

# Currently autocomplete does not work

EOF

pack_cmd "mv $script $(pack_get --prefix)/source/ml.zshrc"
unset script

