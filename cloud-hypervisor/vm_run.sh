#!/bin/bash

BRIDGE_NAME="vm-bridge0"

KERNEL_PATH="/opt/clh/images"
KERNEL_IMAGE="vmlinux"

DISK_PATH="/opt/clh/images"
DISK_IMAGE="custom.qcow2"

echo "setup tap interface"
i_name="vm-tap-${RANDOM}"
sudo ip tuntap add mode tap dev ${i_name}
sudo ip link set ${i_name} master ${BRIDGE_NAME}
sudo ip link set dev ${i_name} up

sudo cloud-hypervisor \
    --kernel "${KERNEL_PATH}/${KERNEL_IMAGE}" \
    --disk path="${DISK_PATH}/${DISK_IMAGE}" \
    --cpus boot=4,max=8 \
    --memory size=4G,hotplug_size=8G,hotplug_method=virtio-mem,shared=on \
    --net "tap=${i_name}" \
    --console off \
    --serial tty \
    --cmdline "console=ttyS0 console=hvc0 root=/dev/vda" \
    --api-socket=/tmp/clh-vm

echo "remove tap interface"
sudo rm -f /tmp/clh-vm
sudo ip link del dev ${i_name}
