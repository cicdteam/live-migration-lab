#!/bin/sh

BRIDGE_NAME="vm-bridge0"
BRIDGE_NET="10.1.1.0/24"

VXLAN_NAME="vm-vxlan0"

echo "clear routing"
sudo ip route del ${BRIDGE_NET} dev ${BRIDGE_NAME}

echo "delete ${VXLAN_NAME} interface if exist"
ip link show dev ${VXLAN_NAME} >/dev/null 2>&1 && sudo ip link del dev ${VXLAN_NAME}

echo "delete bridge ${BRIDGE_NAME} interface if exist"
ip link show dev ${BRIDGE_NAME} >/dev/null 2>&1 && sudo ip link del dev ${BRIDGE_NAME}
