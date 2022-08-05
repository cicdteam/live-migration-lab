#!/bin/bash

set -e

folder=`cd $(dirname "${BASH_SOURCE[@]}"); pwd`

WORKLOADS_DIR="${folder}/workloads"
IMAGES_DIR="/opt/clh/images"
IMAGE_NAME="custom"
IMAGE_SIZE="8G"

SOURCE_FOLDER=$1
if [ -z "${SOURCE_FOLDER}" ]; then
    SOURCE_FOLDER="${folder}/../examples/simple"
fi

mkdir -p "${WORKLOADS_DIR}/custom" "${IMAGES_DIR}"

docker build --quiet --no-cache --pull -t vmdata "${SOURCE_FOLDER}"
docker create --name=vmdata vmdata

rm -f ${IMAGES_DIR}/${IMAGE_NAME}.raw ${IMAGES_DIR}/${IMAGE_NAME}.qcow2
dd if=/dev/zero of=${IMAGES_DIR}/${IMAGE_NAME}.raw bs=1 count=0 seek=${IMAGE_SIZE}
mkfs.ext4 -F ${IMAGES_DIR}/${IMAGE_NAME}.raw
mount -o loop ${IMAGES_DIR}/${IMAGE_NAME}.raw "${WORKLOADS_DIR}/custom"

docker export vmdata | sudo tar x -C "${WORKLOADS_DIR}/custom"

umount "${WORKLOADS_DIR}/custom"
docker rm -f vmdata
docker image rm -f vmdata

qemu-img convert -f raw -O qcow2 ${IMAGES_DIR}/${IMAGE_NAME}.raw ${IMAGES_DIR}/${IMAGE_NAME}.qcow2
rm -f ${IMAGES_DIR}/${IMAGE_NAME}.raw
echo
qemu-img info ${IMAGES_DIR}/${IMAGE_NAME}.qcow2
