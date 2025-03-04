#!/bin/bash

##############################################################################
# macOS support functions
##############################################################################
#
# This script file can be included in build scripts for macOS.
#
##############################################################################

# This script was maded based on the one from upstream
# located at CI/include/build_support_macos.sh

# Setup build environment
CI_WORKFLOW="${CHECKOUT_DIR}/.github/workflows/main-streamlabs.yml"
WORKFLOW_CONTENT=$(/bin/cat "${CI_WORKFLOW}")
CI_DEPS_VERSION=$(echo "${WORKFLOW_CONTENT}" | /usr/bin/sed -En "s/[ ]+DEPS_VERSION_MAC: '([0-9a-z\-]+)'/\1/p")
CI_QT_DEPS_VERSION=$(echo "${WORKFLOW_CONTENT}" | /usr/bin/sed -En "s/[ ]+QT_DEPS_VERSION_MAC: '([0-9a-z\-]+)'/\1/p")
CI_DEPS_HASH_X86_64=$(echo "${WORKFLOW_CONTENT}" | /usr/bin/sed -En "s/[ ]+DEPS_HASH_MAC_X86_64: '([0-9a-f]+)'/\1/p")
CI_DEPS_HASH_ARM64=$(echo "${WORKFLOW_CONTENT}" | /usr/bin/sed -En "s/[ ]+DEPS_HASH_MAC_ARM64: '([0-9a-f]+)'/\1/p")
CI_VLC_VERSION=$(echo "${WORKFLOW_CONTENT}" | /usr/bin/sed -En "s/[ ]+VLC_VERSION_MAC: '([0-9\.]+)'/\1/p")
CI_VLC_HASH=$(echo "${WORKFLOW_CONTENT}" | /usr/bin/sed -En "s/[ ]+VLC_HASH_MAC: '([0-9a-f]+)'/\1/p")
CI_QT_VERSION=$(echo "${WORKFLOW_CONTENT}" | /usr/bin/sed -En "s/[ ]+QT_VERSION_MAC: '([0-9\.]+)'/\1/p" | /usr/bin/head -1)
CI_MACOSX_DEPLOYMENT_TARGET_X86_64=$(echo "${WORKFLOW_CONTENT}" | /usr/bin/sed -En "s/[ ]+MACOSX_DEPLOYMENT_TARGET_X86_64: '([0-9\.]+)'/\1/p")
CI_MACOSX_DEPLOYMENT_TARGET_ARM64=$(echo "${WORKFLOW_CONTENT}" | /usr/bin/sed -En "s/[ ]+MACOSX_DEPLOYMENT_TARGET_ARM64: '([0-9\.]+)'/\1/p")
CI_MACOS_CEF_VERSION=$(echo "${WORKFLOW_CONTENT}" | /usr/bin/sed -En "s/[ ]+CEF_BUILD_VERSION_MAC: '([0-9]+)'/\1/p")
CI_MACOS_CEF_REVISION=$(echo "${WORKFLOW_CONTENT}" | /usr/bin/sed -En "s/[ ]+CEF_BUILD_REVISION_MAC: '([^']+)'/\1/p")
CI_CEF_HASH_X86_64=$(echo "${WORKFLOW_CONTENT}" | /usr/bin/sed -En "s/[ ]+CEF_HASH_MAC_X86_64: '([0-9a-f]+)'/\1/p")
CI_CEF_HASH_ARM64=$(echo "${WORKFLOW_CONTENT}" | /usr/bin/sed -En "s/[ ]+CEF_HASH_MAC_ARM64: '([0-9a-f]+)'/\1/p")
CI_BUILD_CONFIG=$(echo "${WORKFLOW_CONTENT}" | /usr/bin/sed -En "s/[ ]+BUILD_CONFIG: '([0-9a-f]+)'/\1/p")
CI_SPARKLE_VERSION=$(echo "${WORKFLOW_CONTENT}" | /usr/bin/sed -En "s/[ ]+SPARKLE_VERSION: '([0-9\.]+)'/\1/p")
CI_WEBRTC_VERSION=$(echo "${WORKFLOW_CONTENT}" | /usr/bin/sed -En "s/[ ]+WEBRTC_VERSION_MAC: '([0-9a-z\-]+)'/\1/p")
CI_WEBRTC_HASH_X86_64=$(echo "${WORKFLOW_CONTENT}" | /usr/bin/sed -En "s/[ ]+WEBRTC_HASH_MAC_X86_64: '([0-9a-f]+)'/\1/p")
CI_WEBRTC_HASH_ARM64=$(echo "${WORKFLOW_CONTENT}" | /usr/bin/sed -En "s/[ ]+WEBRTC_HASH_MAC_ARM64: '([0-9a-f]+)'/\1/p")
CI_LIBMEDIASOUPCLIENT_VERSION=$(echo "${WORKFLOW_CONTENT}" | /usr/bin/sed -En "s/[ ]+LIBMEDIASOUPCLIENT_VERSION_MAC: '([0-9a-z\-]+)'/\1/p")
CI_LIBMEDIASOUPCLIENT_HASH_X86_64=$(echo "${WORKFLOW_CONTENT}" | /usr/bin/sed -En "s/[ ]+LIBMEDIASOUPCLIENT_HASH_MAC_X86_64: '([0-9a-f]+)'/\1/p")
CI_LIBMEDIASOUPCLIENT_HASH_ARM64=$(echo "${WORKFLOW_CONTENT}" | /usr/bin/sed -En "s/[ ]+LIBMEDIASOUPCLIENT_HASH_MAC_ARM64: '([0-9a-f]+)'/\1/p")

MACOS_VERSION="$(/usr/bin/sw_vers -productVersion)"
MACOS_MAJOR="$(echo ${MACOS_VERSION} | /usr/bin/cut -d '.' -f 1)"
MACOS_MINOR="$(echo ${MACOS_VERSION} | /usr/bin/cut -d '.' -f 2)"

if [ "${TERM-}" -a -z "${CI}" ]; then
    COLOR_RED=$(/usr/bin/tput setaf 1)
    COLOR_GREEN=$(/usr/bin/tput setaf 2)
    COLOR_BLUE=$(/usr/bin/tput setaf 4)
    COLOR_ORANGE=$(/usr/bin/tput setaf 3)
    COLOR_RESET=$(/usr/bin/tput sgr0)
else
    COLOR_RED=""
    COLOR_GREEN=""
    COLOR_BLUE=""
    COLOR_ORANGE=""
    COLOR_RESET=""
fi

## DEFINE UTILITIES ##
check_macos_version() {
    ARCH="${ARCH:-${CURRENT_ARCH}}"
    if [ "${ARCH}" = "x86_64" ]; then
        CI_MACOSX_DEPLOYMENT_TARGET="${CI_MACOSX_DEPLOYMENT_TARGET_X86_64}"
        CI_CEF_HASH="${CI_CEF_HASH_X86_64}"
        CI_DEPS_HASH="${CI_DEPS_HASH_X86_64}"
    elif [ "${ARCH}" = "arm64" ]; then
        CI_MACOSX_DEPLOYMENT_TARGET="${CI_MACOSX_DEPLOYMENT_TARGET_ARM64}"
        CI_CEF_HASH="${CI_CEF_HASH_ARM64}"
        CI_DEPS_HASH="${CI_DEPS_HASH_ARM64}"
    else
        caught_error "Unsupported architecture '${ARCH}' provided"
    fi

    step "Check macOS version..."
    MIN_VERSION=${MACOSX_DEPLOYMENT_TARGET:-${CI_MACOSX_DEPLOYMENT_TARGET}}
    MIN_MAJOR=$(echo ${MIN_VERSION} | /usr/bin/cut -d '.' -f 1)
    MIN_MINOR=$(echo ${MIN_VERSION} | /usr/bin/cut -d '.' -f 2)

    if [ "${MACOS_MAJOR}" -lt "11" -a "${MACOS_MINOR}" -lt "${MIN_MINOR}" ]; then
        error "ERROR: Minimum required macOS version is ${MIN_VERSION}, but running on ${MACOS_VERSION}"
    fi

    if [ "${MACOS_MAJOR}" -ge "11" ]; then
        export CODESIGN_LINKER="ON"
    fi
}

install_homebrew_deps() {
    if ! exists brew; then
        caught_error "Homebrew not found - please install Homebrew (https://brew.sh)"
    fi

    brew bundle --file "${CHECKOUT_DIR}/CI/include/Brewfile" ${QUIET:+--quiet}

    check_curl
}

check_curl() {
    if [ "${MACOS_MAJOR}" -lt "11" -a "${MACOS_MINOR}" -lt "15" ]; then
        if [ ! -d /usr/local/opt/curl ]; then
            step "Install Homebrew curl..."
            brew install curl
        fi

        CURLCMD="/usr/local/opt/curl/bin/curl"
    else
        CURLCMD="curl"
    fi

    if [ "${CI}" -o "${QUIET}" ]; then
        export CURLCMD="${CURLCMD} --silent --show-error --location -O"
    else
        export CURLCMD="${CURLCMD} --progress-bar --location --continue-at - -O"
    fi
}

check_archs() {
    step "Check Architecture..."
    ARCH="${ARCH:-${CURRENT_ARCH}}"
    if [ "${ARCH}" = "universal" ]; then
        CMAKE_ARCHS="x86_64;arm64"
    elif [ "${ARCH}" != "x86_64" -a "${ARCH}" != "arm64" ]; then
        caught_error "Unsupported architecture '${ARCH}' provided"
    else
        CMAKE_ARCHS="${ARCH}"
    fi
}

_add_ccache_to_path() {
    if [ "${CMAKE_CCACHE_OPTIONS}" ]; then
        if [ "${CURRENT_ARCH}" == "arm64" ]; then
            PATH="/opt/homebrew/opt/ccache/libexec:${PATH}"
        else
            PATH="/usr/local/opt/ccache/libexec:${PATH}"
        fi
        status "Compiler Info:"
        local IFS=$'\n'
        for COMPILER_INFO in $(type cc c++ gcc g++ clang clang++ || true); do
            info "${COMPILER_INFO}"
        done
    fi
}