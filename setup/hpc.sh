#!/bin/bash

# Create local rejections based on the hpc cluster

{
    echo bison
    echo otpo
    echo gdis
    echo gromacs
    echo make
    echo llvm
    echo pcre
    echo hydra
    echo mpich
    echo pandas
    echo scons
    echo luaposix
    echo lmod
    echo bigdft
    echo octopus
    echo krypy
} > ../local.reject

{
    echo tinyarray
    echo openblas
    echo boost
    echo nco
    echo espresso
    echo meep
    echo meep-serial
} > ../intel.reject

{
    echo vasp
} > ../gnu.reject