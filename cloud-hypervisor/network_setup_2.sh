#!/bin/sh

BRIDGE_NAME="vm-bridge0"
BRIDGE_NET="10.1.1.0/24"

VXLAN_NAME="vm-vxlan0"
VXLAN_HOST_1="x.x.x.x" # put here real IP address
VXLAN_HOST_2="y.y.y.y" # put here real IP address

echo "create bridge ${BRIDGE_NAME} interface if not exist"
ip link show dev ${BRIDGE_NAME} >/dev/null 2>&1 || sudo ip link add name ${BRIDGE_NAME} type bridge
sudo ip link set dev ${BRIDGE_NAME} up

echo "create ${VXLAN_NAME} interface if not exist"
ip link show dev ${VXLAN_NAME} >/dev/null 2>&1 || sudo ip link add ${VXLAN_NAME} type vxlan id 100 local ${VXLAN_HOST_2} remote ${VXLAN_HOST_1} dstport 4789
sudo ip link set ${VXLAN_NAME} master ${BRIDGE_NAME}
sudo ip link set ${VXLAN_NAME} up

echo "setup routing"
sudo ip route add ${BRIDGE_NET} dev ${BRIDGE_NAME}
