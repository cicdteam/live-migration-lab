#!/bin/bash

VXLAN_HOST_1="x.x.x.x" # put here real IP address
VXLAN_HOST_2="y.y.y.y" # put here real IP address

echo "$(date +"%Y-%m-%d %H:%M:%S") cleanup sockets"
test -S /tmp/clh-vm-migration && sudo rm -f /tmp/clh-vm-migration

echo "$(date +"%Y-%m-%d %H:%M:%S") check if VM running"
vm_status="$(sudo ch-remote --api-socket=/tmp/clh-vm info 2>/dev/null | jq -r '.state')"
if [ "${vm_status}" != "Running" ]; then
    echo "$(date +"%Y-%m-%d %H:%M:%S") VM not started ? exiting..."
    exit
fi

echo "$(date +"%Y-%m-%d %H:%M:%S") trigger migration"
echo "$(date +"%Y-%m-%d %H:%M:%S") run socat"
sudo socat UNIX-LISTEN:/tmp/clh-vm-migration,reuseaddr TCP:${VXLAN_HOST_2}:6000 &
sleep 1
echo "$(date +"%Y-%m-%d %H:%M:%S") send migration"
sudo ch-remote --api-socket=/tmp/clh-vm send-migration unix:/tmp/clh-vm-migration
echo "$(date +"%Y-%m-%d %H:%M:%S") done"
