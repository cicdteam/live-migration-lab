#!/bin/bash

set -e

folder=`cd $(dirname "${BASH_SOURCE[@]}"); pwd`

WORKLOADS_DIR="${folder}/workloads"
IMAGES_DIR="/opt/clh/images"
mkdir -p "${WORKLOADS_DIR}" "${IMAGES_DIR}"

# Checkout source code of a GIT repo with specified branch and commit
# Args:
#   $1: Target directory
#   $2: GIT URL of the repo
#   $3: Required branch
#   $4: Required commit (optional)
checkout_repo() {
    SRC_DIR="$1"
    GIT_URL="$2"
    GIT_BRANCH="$3"
    GIT_COMMIT="$4"

    # Check whether the local HEAD commit same as the requested commit or not.
    # If commit is not specified, compare local HEAD and remote HEAD.
    # Remove the folder if there is difference.
    if [ -d "$SRC_DIR" ]; then
        pushd $SRC_DIR
        git fetch
        SRC_LOCAL_COMMIT=$(git rev-parse HEAD)
        if [ -z "$GIT_COMMIT" ]; then
            GIT_COMMIT=$(git rev-parse remotes/origin/"$GIT_BRANCH")
        fi
        popd
        if [ "$SRC_LOCAL_COMMIT" != "$GIT_COMMIT" ]; then
            rm -rf "$SRC_DIR"
        fi
    fi

    # Checkout the specified branch and commit (if required)
    if [ ! -d "$SRC_DIR" ]; then
        git clone --depth 1 "$GIT_URL" -b "$GIT_BRANCH" "$SRC_DIR"
        if [ "$GIT_COMMIT" ]; then
            pushd "$SRC_DIR"
            git fetch --depth 1 origin "$GIT_COMMIT"
            git reset --hard FETCH_HEAD
            popd
        fi
    fi
}

build_custom_linux() {
    ARCH=$(uname -m)
    SRCDIR=${folder}
    LINUX_CUSTOM_DIR="$WORKLOADS_DIR/linux-custom"
    LINUX_CUSTOM_BRANCH="ch-5.15.12"
    LINUX_CUSTOM_URL="https://github.com/cloud-hypervisor/linux.git"

    checkout_repo "$LINUX_CUSTOM_DIR" "$LINUX_CUSTOM_URL" "$LINUX_CUSTOM_BRANCH"

    cp $SRCDIR/linux-config-${ARCH} $LINUX_CUSTOM_DIR/.config

    pushd $LINUX_CUSTOM_DIR
    make -j `nproc`
    if [ ${ARCH} == "x86_64" ]; then
       cp vmlinux "$IMAGES_DIR/" || exit 1
    elif [ ${ARCH} == "aarch64" ]; then
       cp arch/arm64/boot/Image "$IMAGES_DIR/" || exit 1
       cp arch/arm64/boot/Image.gz "$IMAGES_DIR/" || exit 1
    fi
    popd
}

# Build custom kernel based on virtio-pmem and virtio-fs upstream patches
build_custom_linux
