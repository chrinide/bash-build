add_package --build generic ftp://ftp.cwru.edu/pub/bash/readline-6.3.tar.gz

pack_set -s $IS_MODULE
pack_set --lib "-lreadline -lncurses"


pack_set --install-query $(pack_get --prefix)/lib/libreadline.so

# Install commands that it should run
pack_cmd "./configure --prefix=$(pack_get --prefix)"

# Make commands
pack_cmd "make"
pack_cmd "make install"
