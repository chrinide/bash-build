source build-generic.sh

module purge

source source-gnu.sh
new_build --name gnu \
    --installation-path /opt \
    --module-path /opt/modules \
    --build-path .compile \
    --build-module-path "--package --version $(get_c)" \
    --build-installation-path "--package --version $(get_c)" \
    --source source-gnu-5.sh \
    --default-module gcc[5.3.0]

build_set --default-choice[gnu] linalg openblas atlas blas

mkdir -p $(build_get --module-path[gnu])-npa
mkdir -p $(build_get --module-path[gnu])-npa-apps

build_set --default-module-version[gnu]

source source-gnu-debug.sh
new_build --name debug \
    --installation-path /opt \
    --module-path /opt/modules \
    --build-path .compile \
    --build-module-path "--package --version $(get_c)" \
    --build-installation-path "--package --version $(get_c)" \
    --source source-gnu-5-debug.sh \
    --default-module gcc[5.3.0]

build_set --default-choice[debug] linalg openblas atlas blas

# Override default build to gnu
_default_build=gnu