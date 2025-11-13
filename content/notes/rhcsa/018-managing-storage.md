---
title: "Managing Storage"
tags: [linux, rhcsa]
published: 2025-11-12T08:11:09+00:00
feature: false
draft: true
hide: true
---

References: 
- [Fedora - Disk Partitions](https://docs.fedoraproject.org/en-US/fedora/f36/install-guide/appendixes/Disk_Partitions/)
- [Arch - Partitioning](https://wiki.archlinux.org/title/Partitioning)
- [Arch - File Systems](https://wiki.archlinux.org/title/File_systems)
- [Arch - fstab](https://wiki.archlinux.org/title/File_systems)

## Listing block devices
```bash
lsblk
```
Knowledge check
1. What type of device would /dev/sdx commonly be?
1. What type of device would /dev/vdx commonly be?
1. Where does lsblk get its information from?

:::details Answers
1. SCSI, SATA, and disks connected via USB
1. KVM virtual machines
1. The kernel partition table: /proc/partitions

:::

## Creating partitions
```bash
fdisk {device}
```

## Creating and mounting filesystems
Creating filesystems
```bash
mkfs.xfs /dev/device
mkfs.ext4 /dev/device
mkfs.vfat /dev/device
```
Mounting devices
```bash
mount /dev/device /mnt/path # mount a device
umount /mnt/path # unmount a device
```

Finding mounts
```bash
mount # shows all mounted filesystems, including kernel mounts
findmnt # shows all mounts in tree-like structure
lsblk
```

Knowledge Check
- Which filesystem offers multi-OS support?
- Which filesystem is used for a UEFI boot partition?
- Which filesystem is the default for RHEL?

:::details Answers
1. vfat
1. vfat
1. XFS

:::

## Mounting partitions automatically
To mount a filesystem automatically, add entry to /etc/fstab.
- Always create a backup before editing
- Always verify correctness before rebooting (`mount -a` or `findmnt --verify`)
```text
device mount-path filesystem defaults 0 0
```
The last two entries are legacy options. Rarely used on modern systems.

Super useful troubleshooting tip: If the fstab is broken (or something else),
you may not be able to access a console if there is no root password. In this
case, edit the GRUB boot command by pressing `e` at the boot menu. Remove `rhgb
quiet` from the end of the line starting with `linux` and add `init=/bin/bash`.
The filesystem will be mounted in read-only mode. Use `mount -o remount,rw /`
and make the necessary changes. After making file changes, use `sync` to ensure
there are no changes pending in cache before reboot.

## Using UUID and labels
Block device names (eg /dev/sdb) are subject to change.

Knowledge Check
1. What command can be used to determine UUIDs?
1. What command can be used to set a label for an ext filesystem?
1. What command can be used to set a label for an XFS filesystem?
1. How can you set a label while creating a filesystem?

:::details Answers
1. `blkid`
1. `tune2fs -L`
1. `xfs_admin -L`
1. `mkfs.* -L`

:::

## Systemd mounts

Example systemd mount: /etc/systemd/system/files.mount
```text
[Unit]
Documentation=man:fstab(5) man:systemd-fstab-generator(8)

[Mount]
What=/dev/disk/by-uuid/{UUID}
Where=/mnt/path
Type=ext4
Options=nofail

[Install]
WantedBy=multi-user.target
```
Note: Examples copied from /run/systemd/generator will be missing the Install
section.

Knowledge Check
1. How can you view the systemd mounts?

:::details Answers
1. Cat the files in /run/systemd/generator

:::

## Creating a swap partition

Create swap space from block device
- Set partition type to linux-swap
- Use `mkswap` to create the swap filesystem
- Activate using `swapon`


## Lab Exercise
- Create a partition with a size of 1GiB. Format it with ext4, and mount it
  persistently on /mounts/files using its UUID
- Create a 512 MiB swap partition and mount it persistently
- Create another 1G partition of type Linux Filesystem. Format it with XFS and
  intentionally put an incorrect UUID number in the fstab with the default mount
  settings. Reboot the VM and recover.
