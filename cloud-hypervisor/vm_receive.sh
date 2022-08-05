#!/bin/bash

BRIDGE_NAME="vm-bridge0"

function get_vm () {
    while true; do
        if [ -S /tmp/clh-vm ]; then
            echo "$(date +"%Y-%m-%d %H:%M:%S") found hypervisor socket for clone"
            echo "$(date +"%Y-%m-%d %H:%M:%S") setup clone to receive VM"
            sudo ch-remote --api-socket=/tmp/clh-vm receive-migration unix:/tmp/clh-vm-migration &
            sleep 1
            echo "$(date +"%Y-%m-%d %H:%M:%S") start socat"
            sudo socat TCP-LISTEN:6000,reuseaddr UNIX-CLIENT:/tmp/clh-vm-migration &
            break
        fi
        sleep 1
    done
}

function add_tap_to_bridge () {
    echo "$(date +"%Y-%m-%d %H:%M:%S") watching for vm-tap interfaces"
    while true; do
        vmtaplist=$(ip -j tuntap show | jq -r '.[].ifname'|grep vm-tap-)
        for i in ${vmtaplist}; do
            # check if vm-tap interface not belongs to bridge
            if [ "$(ip -j link show dev ${i} | jq -Mr '.[].master')" = "null" ]; then
                # this vm-tap not linked with bridge
                echo "$(date +"%Y-%m-%d %H:%M:%S") adding '${i}' interface to '${BRIDGE_NAME}' bridge"
                sudo ip link set ${i} master ${BRIDGE_NAME}
            fi
        done
        sleep 1
    done
}

echo "$(date +"%Y-%m-%d %H:%M:%S") cleanup sockets"
test -S /tmp/clh-vm           && sudo rm -f /tmp/clh-vm
test -S /tmp/clh-vm-migration && sudo rm -f /tmp/clh-vm-migration

echo "$(date +"%Y-%m-%d %H:%M:%S") run migration receiver in background"
get_vm &
add_tap_to_bridge &

echo "$(date +"%Y-%m-%d %H:%M:%S") start hypervisor for clone"
sudo cloud-hypervisor --api-socket=/tmp/clh-vm
echo "$(date +"%Y-%m-%d %H:%M:%S") done"
