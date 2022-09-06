export PATH=/usr/local/opt/ccache/libexec:$PATH
set -e
set -v

mkdir packed_build
PACKED_BUILD=$PWD/packed_build
mkdir build

if [ "${XCODE}" ]; then
    GENERATOR="Xcode"
else
    GENERATOR="Ninja"
fi

CHECKOUT_DIR="$(/usr/bin/git rev-parse --show-toplevel)"
source "${CHECKOUT_DIR}/slobs_CI/01_install_dependencies.sh"
DEPS_BUILD_DIR="${CHECKOUT_DIR}/../obs-build-dependencies"
BUILD_DIR="${CHECKOUT_DIR}/build"

cmake \
    -DCMAKE_OSX_DEPLOYMENT_TARGET=${MACOSX_DEPLOYMENT_TARGET:-${CI_MACOSX_DEPLOYMENT_TARGET}} \
    -S ${CHECKOUT_DIR} -B ${BUILD_DIR} \
    -G ${GENERATOR} \
    -DVLC_PATH="${DEPS_BUILD_DIR}/vlc-${VLC_VERSION:-${CI_VLC_VERSION}}" \
    -DENABLE_VLC=ON \
    -DCEF_ROOT_DIR="${DEPS_BUILD_DIR}/cef_binary_${MACOS_CEF_BUILD_VERSION:-${CI_MACOS_CEF_VERSION}}_macos_${ARCH:-x86_64}" \
    -DBROWSER_LEGACY=$(test "${MACOS_CEF_BUILD_VERSION:-${CI_MACOS_CEF_VERSION}}" -le 3770 && echo "ON" || echo "OFF") \
    -DCMAKE_PREFIX_PATH="${DEPS_BUILD_DIR}/obs-deps" \
    -DCMAKE_OSX_ARCHITECTURES=${CMAKE_ARCHS} \
    -DCMAKE_INSTALL_PREFIX=$PACKED_BUILD \
    -DCMAKE_BUILD_TYPE=${CI_BUILD_CONFIG} \
    -DENABLE_UI=false \
    -DDISABLE_UI=true \
    -DCOPIED_DEPENDENCIES=false \
    -DCOPY_DEPENDENCIES=true \
    -DENABLE_SCRIPTING=false \
    -DBROWSER_FRONTEND_API_SUPPORT=false \
    -DBROWSER_PANEL_SUPPORT=false \
    -DUSE_UI_LOOP=true \
    -DCHECK_FOR_SERVICE_UPDATES=true \
    ${QUIET:+-Wno-deprecated -Wno-dev --log-level=ERROR}

cmake --build ${BUILD_DIR} --target install --config ${CI_BUILD_CONFIG} -v