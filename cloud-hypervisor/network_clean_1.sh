#!/bin/sh

BRIDGE_NAME="vm-bridge0"
BRIDGE_NET="10.1.1.0/24"

VXLAN_NAME="vm-vxlan0"

echo "delete ${VXLAN_NAME} interface if exist"
ip link show dev ${VXLAN_NAME} >/dev/null 2>&1 && sudo ip link del dev ${VXLAN_NAME}

echo "delete bridge ${BRIDGE_NAME} interface if exist"
ip link show dev ${BRIDGE_NAME} >/dev/null 2>&1 && sudo ip link del dev ${BRIDGE_NAME}

echo "clear NAT"
sudo iptables -t nat -D POSTROUTING -s ${BRIDGE_NET} ! -d ${BRIDGE_NET} -j MASQUERADE
sudo iptables        -D FORWARD -i ${BRIDGE_NAME} -j ACCEPT
sudo iptables        -D FORWARD -o ${BRIDGE_NAME} -m state --state RELATED,ESTABLISHED -j ACCEPT
