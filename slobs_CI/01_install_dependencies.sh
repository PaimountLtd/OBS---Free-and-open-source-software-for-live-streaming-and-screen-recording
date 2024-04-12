#!/bin/bash

##############################################################################
# macOS dependency management function
##############################################################################
#
# This script file can be included in build scripts for macOS or run directly.
#
##############################################################################

# This script was maded based on the one from upstream
# located at CI/macos/01_install_dependencies.sh

# Halt on errors
set -eE

install_obs-deps() {
    echo "https://obs-studio-deployment.s3-us-west-2.amazonaws.com/macos-deps-${1}-${ARCH:-x86_64}-sl.tar.xz"
    status "Set up precompiled macOS OBS dependencies v${1}"
    ensure_dir "${DEPS_BUILD_DIR}"
    step "Download..."
    wget --quiet --retry-connrefused --waitretry=1 "https://obs-studio-deployment.s3-us-west-2.amazonaws.com/macos-deps-${1}-${ARCH:-x86_64}-sl.tar.xz"
    mkdir -p obs-deps
    step "Unpack..."
    /usr/bin/tar -xf "./macos-deps-${1}-${ARCH:-x86_64}-sl.tar.xz" -C ./obs-deps
    /usr/bin/xattr -r -d com.apple.quarantine ./obs-deps
}

install_qt-deps() {
    status "Set up precompiled dependency Qt v${1}"
    ensure_dir "${DEPS_BUILD_DIR}"
    step "Download..."

    if [[ -n ${CI} ]]; then
        _ARCH='universal'
    else
        _ARCH="${ARCH:-x86_64}"
    fi

    wget --quiet --retry-connrefused --waitretry=1 "https://github.com/obsproject/obs-deps/releases/download/${1}/macos-deps-qt6-${1}-${_ARCH:-x86_64}.tar.xz"
    mkdir -p obs-deps
    step "Unpack..."
    /usr/bin/tar -xf "./macos-deps-qt6-${1}-${_ARCH}.tar.xz" -C ./obs-deps
    /usr/bin/xattr -r -d com.apple.quarantine ./obs-deps
}

install_vlc() {
    status "Set up dependency VLC v${1}"
    ensure_dir "${DEPS_BUILD_DIR}"
    unset _SKIP

    if [ "${CI}" -a "${RESTORED_VLC}" ]; then
        _SKIP=TRUE
    elif [ -d "${DEPS_BUILD_DIR}/vlc-${1}" -a -f "${DEPS_BUILD_DIR}/vlc-${1}/include/vlc/vlc.h" ]; then
        _SKIP=TRUE
    fi

    if [ -z "${_SKIP}" ]; then
        step "Download..."
        wget --quiet --retry-connrefused --waitretry=1 "https://downloads.videolan.org/vlc/${1}/vlc-${1}.tar.xz"
        step "Unpack..."
        /usr/bin/tar -xf vlc-${1}.tar.xz
    else
        step "Found existing VLC..."
    fi
}

install_sparkle() {
    status "Set up dependency Sparkle v${1}"
    ensure_dir "${DEPS_BUILD_DIR}"
    unset _SKIP

    if [ "${CI}" -a "${RESTORED_SPARKLE}" ]; then
        _SKIP=TRUE
    elif [ -d "${DEPS_BUILD_DIR}/obs-deps/lib/Sparkle.framework" -a -f "${DEPS_BUILD_DIR}/obs-deps/lib/Sparkle.framework/Sparkle" ]; then
        _SKIP=TRUE
    fi

    if [ -z "${_SKIP}" ]; then
        step "Download..."
        wget --quiet --retry-connrefused --waitretry=1 "https://github.com/sparkle-project/Sparkle/releases/download/${1}/Sparkle-${1}.tar.xz"
        step "Unpack..."
        ensure_dir "${DEPS_BUILD_DIR}/sparkle"
        /usr/bin/tar -xf ../Sparkle-${1}.tar.xz
        cp -cpR "${DEPS_BUILD_DIR}"/sparkle/Sparkle.framework "${DEPS_BUILD_DIR}"/obs-deps/lib/
    else
        step "Found existing Sparkle Framework..."
    fi
}

install_cef() {
    status "Set up dependency CEF v${1}"
    ensure_dir "${DEPS_BUILD_DIR}"
    unset _SKIP

    if [ "${CI}" -a "${RESTORED_CEF}" ]; then
        _SKIP=TRUE
    elif [ -d "${DEPS_BUILD_DIR}/cef_binary_${1}_macos_${ARCH:-x86_64}" -a -f "${DEPS_BUILD_DIR}/cef_binary_${1}_macos_${ARCH:-x86_64}/build/libcef_dll_wrapper/libcef_dll_wrapper.a" ]; then
        _SKIP=TRUE
    fi

    if [ -z "${_SKIP}" ]; then
        step "Download..."
        wget --quiet --retry-connrefused --waitretry=1 "https://obs-studio-deployment.s3-us-west-2.amazonaws.com/cef_binary_${1}_macos_${ARCH:-x86_64}.tar.xz"
        step "Unpack..."
        /usr/bin/tar -xf cef_binary_${1}_macos_${ARCH:-x86_64}.tar.xz
        cd cef_binary_${1}_macos_${ARCH:-x86_64}
        step "Fix tests..."

        /usr/bin/sed -i '.orig' '/add_subdirectory(tests\/ceftests)/d' ./CMakeLists.txt
        /usr/bin/sed -E -i '' 's/"10.(9|10|11)"/"'${MACOSX_DEPLOYMENT_TARGET:-${CI_MACOSX_DEPLOYMENT_TARGET}}'"/' ./cmake/cef_variables.cmake

        step "Run CMake..."
        check_ccache
        cmake ${CCACHE_OPTIONS} ${QUIET:+-Wno-deprecated -Wno-dev --log-level=ERROR} \
            -S . \
            -B build \
            -G Ninja \
            -DPROJECT_ARCH=${CMAKE_ARCHS:-x86_64} \
            -DCMAKE_BUILD_TYPE=Release \
            -DCEF_COMPILER_FLAGS_RELEASE="-Wno-deprecated" \
            -DCMAKE_OSX_DEPLOYMENT_TARGET=${MACOSX_DEPLOYMENT_TARGET:-${CI_MACOSX_DEPLOYMENT_TARGET}}

        step "Build CEF v${1}..."
        cmake --build build
        mkdir -p build/libcef_dll
    else
        step "Found existing Chromium Embedded Framework and loader library..."
    fi
}

install_webrtc() {
    WEBRTC_DIST_FOLDER=webrtc-dist-osx-${1}-${ARCH:-x86_64}
    WEBRTC_DIST_FILENAME=${WEBRTC_DIST_FOLDER}.zip
    WEBRTC_DIST_URL=https://obs-studio-deployment.s3-us-west-2.amazonaws.com/${WEBRTC_DIST_FILENAME}
    WEBRTC_DIST_FINAL_FOLDER=webrtc-dist

    echo "${WEBRTC_DIST_URL}"
    status "Set up precompiled macOS WebRTC ${1}"
    ensure_dir "${DEPS_BUILD_DIR}"
    step "Download..."
    wget --quiet --retry-connrefused --waitretry=1 "${WEBRTC_DIST_URL}"
    step "Unpack..."
    /usr/bin/tar -xf "./${WEBRTC_DIST_FILENAME}"
    rm -rf "${WEBRTC_DIST_FINAL_FOLDER}"
    mv "${WEBRTC_DIST_FOLDER}" "${WEBRTC_DIST_FINAL_FOLDER}"
    /usr/bin/xattr -r -d com.apple.quarantine "./${WEBRTC_DIST_FINAL_FOLDER}"
}

install_libmediasoupclient() {
    LIBMEDIASOUPCLIENT_DIST_FOLDER=libmediasoupclient-dist-osx-${1}-${ARCH:-x86_64}
    LIBMEDIASOUPCLIENT_DIST_FILENAME=${LIBMEDIASOUPCLIENT_DIST_FOLDER}.zip
    LIBMEDIASOUPCLIENT_DIST_URL=https://obs-studio-deployment.s3-us-west-2.amazonaws.com/${LIBMEDIASOUPCLIENT_DIST_FILENAME}
    LIBMEDIASOUPCLIENT_DIST_FINAL_FOLDER=libmediasoupclient-dist

    echo "${LIBMEDIASOUPCLIENT_DIST_URL}"
    status "Set up precompiled macOS libmediasoupclient ${1}"
    ensure_dir "${DEPS_BUILD_DIR}"
    step "Download..."
    wget --quiet --retry-connrefused --waitretry=1 "${LIBMEDIASOUPCLIENT_DIST_URL}"
    step "Unpack..."
    /usr/bin/tar -xf "./${LIBMEDIASOUPCLIENT_DIST_FILENAME}" && mv "${LIBMEDIASOUPCLIENT_DIST_FOLDER}" "${LIBMEDIASOUPCLIENT_DIST_FINAL_FOLDER}"
    /usr/bin/xattr -r -d com.apple.quarantine "./${LIBMEDIASOUPCLIENT_DIST_FINAL_FOLDER}"
}

install_dependencies() {
    status "Install Homebrew dependencies"
    trap "caught_error 'install_dependencies'" ERR

    BUILD_DEPS=(
        "obs-deps ${MACOS_DEPS_VERSION:-${CI_DEPS_VERSION}} ${MACOS_DEPS_HASH:-${CI_DEPS_HASH}}"
        "qt-deps ${MACOS_QT_DEPS_VERSION:-${CI_QT_DEPS_VERSION}} ${QT_HASH:-${CI_QT_HASH}}"
        "cef ${MACOS_CEF_BUILD_VERSION:-${CI_MACOS_CEF_VERSION}} ${CEF_HASH:-${CI_CEF_HASH}}"
        "vlc ${VLC_VERSION:-${CI_VLC_VERSION}} ${VLC_HASH:-${CI_VLC_HASH}}"
        "webrtc ${WEBRTC_VERSION:-${CI_WEBRTC_VERSION}} ${MACOS_WEBRTC_HASH:-${CI_WEBRTC_HASH}}"
        "libmediasoupclient ${LIBMEDIASOUPCLIENT_VERSION:-${CI_LIBMEDIASOUPCLIENT_VERSION}} ${MACOS_LIBMEDIASOUPCLIENT_HASH:-${CI_LIBMEDIASOUPCLIENT_HASH}}"
    )

    install_homebrew_deps

    for DEPENDENCY in "${BUILD_DEPS[@]}"; do
        set -- ${DEPENDENCY}
        trap "caught_error ${DEPENDENCY}" ERR
        FUNC_NAME="install_${1}"
        ${FUNC_NAME} ${2} ${3} ${4}
    done
}

install-dependencies-standalone() {
    CHECKOUT_DIR="$(/usr/bin/git rev-parse --show-toplevel)"
    DEPS_BUILD_DIR="${CHECKOUT_DIR}/../obs-build-dependencies"
    source "${CHECKOUT_DIR}/CI/include/build_support.sh"
    source "${CHECKOUT_DIR}/slobs_CI/build_support_macos.sh"

    status "Setup of OBS build dependencies"
    check_macos_version
    check_archs
    install_dependencies
}

print_usage() {
    echo -e "Usage: ${0}\n" \
            "-h, --help                     : Print this help\n" \
            "-q, --quiet                    : Suppress most build process output\n" \
            "-v, --verbose                  : Enable more verbose build process output\n" \
            "-a, --architecture             : Specify build architecture (default: x86_64, alternative: arm64)\n"
}

install-dependencies-main() {
    if [ -z "${_RUN_OBS_BUILD_SCRIPT}" ]; then
        while true; do
            case "${1}" in
                -h | --help ) print_usage; exit 0 ;;
                -q | --quiet ) export QUIET=TRUE; shift ;;
                -v | --verbose ) export VERBOSE=TRUE; shift ;;
                -a | --architecture ) ARCH="${2}"; shift 2 ;;
                -- ) shift; break ;;
                * ) break ;;
            esac
        done

        install-dependencies-standalone
    fi
}

install-dependencies-main $*
