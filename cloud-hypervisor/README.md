## Practical experiments with VM live migration based on [cloud-hypervisor](https://github.com/cloud-hypervisor/cloud-hypervisor)

TL;DR

- set real values for variables `VXLAN_HOST_1` and `VXLAN_HOST_2` in [network_setup_1.sh](network_setup_1.sh), [network_setup_2.sh](network_setup_2.sh) and [vm_send.sh](vm_send.sh) files
- run [network_setup_1.sh](network_setup_1.sh) on host #1
- run [network_setup_2.sh](network_setup_2.sh) on host #2
- on host #1 build linux kernel adopted for cloud-hypervisor [scripts/build_kernel.sh](scripts/build_kernel.sh) (it will create `/opt/clh/images/vmlinux `)
- on host #1 build VM disk image [scripts/build_image.sh](scripts/build_image.sh) (it will create `/opt/clh/images/custom.qcow2`)
- repeat kernel and VM disk builds on host #2 or just copy them to `/opt/clh/images` folder there
- run [vm_run.sh](vm_run.sh) on host #1, check VM connected to internet (`ping 8.8.8.8`)
- run [vm_receive.sh](vm_receive.sh) on host #2 (it will wait VM there)
- run [vm_send.sh](vm_send.sh) on host #1 (in another terminal), wait when live migration finish
- check VM migrated on host #2 (you should see ping continues there)

Tear down

- exit from VM console (it will terminate VM by `poweroff` command)
- run [network_clean_1.sh](network_clean_1.sh) on host #1
- run [network_clean_2.sh](network_clean_2.sh) on host #2

### VM disk image

There are several [examples](examples) with disk image definitions. It uses docker images as source for VM image.
By default script [scripts/build_image.sh](scripts/build_image.sh) uses [examples/simple](examples/simple) (latest Alpine OS)

<details>
<summary>build Debian 11 based VM</summary>

```
$ sudo ./scripts/build_image.sh examples/debian

sha256:a710a54a59e993e1a0b2f786307269e240195656e2a98d36110dcd30a6ba8521
7d5ab14b0a6f0e46462a487d09fd4547cab722482c6ed5268f90f0e67b782f1a
0+0 records in
0+0 records out
0 bytes copied, 8.106e-05 s, 0.0 kB/s
mke2fs 1.45.5 (07-Jan-2020)
Discarding device blocks: done
Creating filesystem with 2097152 4k blocks and 524288 inodes
Filesystem UUID: 79fb2eb7-ae2d-40b9-8d21-90708887e699
Superblock backups stored on blocks: 
    32768, 98304, 163840, 229376, 294912, 819200, 884736, 1605632

Allocating group tables: done
Writing inode tables: done
Creating journal (16384 blocks): done
Writing superblocks and filesystem accounting information: done 

vmdata
Untagged: vmdata:latest
Deleted: sha256:a710a54a59e993e1a0b2f786307269e240195656e2a98d36110dcd30a6ba8521
Deleted: sha256:2b59305713ce34c8dd3e733e339d40f87e999620a8e08efead2bf654f1f8404d
Deleted: sha256:812e2c7e7d00626e1bb8645d7d0b8edcb9d984b7bca603e7ea1366a8753501af
Deleted: sha256:3f78e5a197cd0f723826cf349ef1dedea71f3fc278c0055bcb7567c8d7302102
Deleted: sha256:17c54e8fa2e2dc3b59b45c6e33a3f1aebef6f62ca06701c80eccfd9823f52485
Deleted: sha256:f0e98f84e845b39902fb607ff85e49df6e7d61f56b96f0ddac3fdbca41c34dd0
Deleted: sha256:3fb6914644615ba4f1833be1b407cdc455c91221f7eb0137d312dcf0cea4a586
Deleted: sha256:5e0a88e99c04150d98294ac376f782d32ccdebe3cddeaf3b3fca5165ef68980c

image: /opt/clh/images/custom.qcow2
file format: qcow2
virtual size: 8 GiB (8589934592 bytes)
disk size: 229 MiB
cluster_size: 65536
Format specific information:
    compat: 1.1
    lazy refcounts: false
    refcount bits: 16
    corrupt: false
```

</details>

<details>
<summary>build Alpine based VM with PostgreSQL 14.4 installed</summary>

```
$ sudo ./scripts/build_image.sh examples/postgres

sha256:c707fa0787da7c8be8742d8f7d676531f94bb2187b51d8a39924edb32e912916
b2b2d9e5223583f3bc244f19429ffbc1b1212d60e7734f2aff76369970e6a88c
0+0 records in
0+0 records out
0 bytes copied, 6.6701e-05 s, 0.0 kB/s
mke2fs 1.45.5 (07-Jan-2020)
Discarding device blocks: done
Creating filesystem with 2097152 4k blocks and 524288 inodes
Filesystem UUID: 7cc9bab4-d81e-4f2b-b35d-b6982be9c120
Superblock backups stored on blocks: 
    32768, 98304, 163840, 229376, 294912, 819200, 884736, 1605632

Allocating group tables: done
Writing inode tables: done
Creating journal (16384 blocks): done
Writing superblocks and filesystem accounting information: done

vmdata
Untagged: vmdata:latest
Deleted: sha256:c707fa0787da7c8be8742d8f7d676531f94bb2187b51d8a39924edb32e912916
Deleted: sha256:5fa82cd1ca23a9ecf50ba9666ac66d0faf11b7c8bba4c41e924a3b692f1457c4
Deleted: sha256:525a10b65488f54ae846764e623f3176db6b928e301e013b43dddc0778539c32
Deleted: sha256:e35eb252120bd8afc04a51c815bc357be2ddc3a4e0ad2754e28bffc6ec725814
Deleted: sha256:a2d918888bd4a24fb650ad18713c60a24f15e2f265b9ae5c9e8ca020564a7d6a
Deleted: sha256:988ac30a237d54b89966eac7521f834c1a5db8ca51d3798d3a69422fe272f09b
Deleted: sha256:7ba15b9793506fc50eb386da3147f2a0832725cac260eea3d4d8687c8e4bb371
Deleted: sha256:2a9fa59acea8ef525fbec1e9c6f33f49980f79e35b533432dada78bcf755b1ff

image: /opt/clh/images/custom.qcow2
file format: qcow2
virtual size: 8 GiB (8589934592 bytes)
disk size: 224 MiB
cluster_size: 65536
Format specific information:
    compat: 1.1
    lazy refcounts: false
    refcount bits: 16
    corrupt: false
```

</details>

