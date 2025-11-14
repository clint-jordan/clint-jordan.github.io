---
title: "Managing Advanced Storage"
tags: [linux, rhcsa]
published: 2025-11-13T15:41:40+00:00
feature: false
draft: true
hide: true
---

## Advanced Storage Solutions
[Arch - LVM](https://wiki.archlinux.org/title/LVM)
[RHEL - LVM](https://docs.redhat.com/en/documentation/red_hat_enterprise_linux/10/pdf/configuring_and_managing_logical_volumes/Red_Hat_Enterprise_Linux-10-Configuring_and_managing_logical_volumes-en-US.pdf)
[Stratis](https://stratis-storage.github.io/)

## Creating a Logical Volume
1. Create a partition of type `lvm`
1. Create physical volume with `pvcreate /dev/partition`
1. Create volume group with `vgcreate {vgroup} /dev/partition`
   - Use the `-s` option to define a non standard extent size
1. Create logical volume with `lvcreate -n {lv} -L 1G {vgroup}`
   - Use `-l` instead of `-L` to specify the number of extents
1. Create a filesystem
1. Use `vgdisplay` to get UUID and mount in fstab
   - Alternatively, use `/dev/lvgname/lvname`, as these don't change like device
     names

## Device Mapper and LVM Device Names
[Wikipedia](https://en.wikipedia.org/wiki/Device_mapper)

## Resizing LVM Logical Volumes
- Use `vgs` to verify that the volume group has unused disk space 
- Use `vgextend` to add one or more PVs to the VG
- Use `lvextend -r -L +1G` to grow the logical volume, including the filesystem
  it's hosting (`-r`)
  - `resize2fs` is a resize utility for ext filesystems
  - `xfs_growfs` can be used to grow an XFS filesystem
  - `lvextend -r -l +50%FREE` will use half the available free extents
- If the volume is mounted `df -h` will show the newly available space
  - Or `vgs` or `vgdisplay`

## Reducing a Volume Group
[RHEL](https://docs.redhat.com/en/documentation/red_hat_enterprise_linux/6/html/logical_volume_manager_administration/vg_remove_pv)
- Use `pvs` to ensure that PFree > 0
- Use `pvmove` to moved extents from the volume being removed to the remaining
  volumes(s)
- Use `vgreduce` to complete the removal

### Exercise
1. Use fdisk to create 2 partitions, p1 and p2 for reference, with a size of 1G
  each and set the type to `lvm`
1. Create a volume group, demo, including only the first partition, p1
1. Add a logical volume, vol1, of 500M to the group
1. Add the second partition, p2, to the volume group
1. Extend the logical volume, vol1, using extents *from the second partition*
1. Put an ext4 filesystem on the logical volume
1. Mount vol1 to /mnt and use `df -h` to view
1. Use `dd if=/dev/zero of=/mnt/bigfile bs=1M count=1100` to ensure data is on
  both physical volumes
1. Move all used extents from partition p2 to p1
1. Print information for the physical volumes. Ensure that p2 is now unused.
1. Remove p2 from the volume group

:::details Solution
1. `fdisk`
1. `vgcreate vgdemo /dev/p1`
1. `lvcreate -n vol1 -L 500M`
1. `vgextend vgdemo /dev/p2`
1. `lvextend -n /dev/vgdemo/vol1 -L 250M /dev/p2`
1. `mkfs.ext4 /dev/vgdemo/vol1`
1. `mount /dev/vgdemo/vol1 /mnt`
1. `dd if=/dev/zero of=/mnt/bigfile bs=1M count=550`
1. `pvmove -v /dev/p2 /dev/p1`
   - `-v is for verbose, not required`
1. `pvs`
1. `vgreduce vgdemo /dev/p1`

:::

## Stratis Pools

```bash
dnf install stratisd stratis-cli
systemctl enable --now stratisd
stratis pool create mypool /dev/partition1
stratis pool list
stratis pool add-data mypool /dev/partition2
stratis blockdev list
stratis fs create mypool myfs
stratis fs list
mkdir /myfs
lsblk --output=UUID /dev/stratis/mypool/myfs >> /etc/fstab
```
Modify /etc/fstab
```text
UUID=... /myfs xfs defaults,x-systemd.requires=stratisd.service 0 0"
```

Knowledge Check
1. What is the minimal size of a stratis volume?
1. What filesystem must a stratus volume have?

:::details Answers
1. 4G
1. XFS

:::

## Stratis Snapshots

```bash
dd if=/dev/zero of=/myfs/bigfile bs=1M count=2000
stratis pool list
stratis fs list
stratis fs snapshot mypool myfs myfs-snap
stratis fs list
rm /myfs/bigfile
mkdir /myfs-snap
mount /dev/stratis/mypool/myfs-snap /myfs-snap
ls -l /myfs-snap
umount /myfs-snap
stratis fs destroy mypool myfs-snap
```

Knowledge Check
1. Is a snapshot a backup?
1. What is contained in a snapshot

:::details Answers
1. No, a snapshot is a metadata copy that allows you to access the state of the
   snapshot at any time. It differs from a backup in that if the original volume
   is destroyed, the snapshot is also lost.
1. Metadata

:::

## Lab Exercise: LVM
- Create an logical volume 1G in size with the name lvdata.
- Format lvdata with the XFS filesystem and mount it persistently on
  /mounts/lvdata
- Increase the size of lvdata by 100 extents
- Add another device to the volume group that lvdata belongs
- Add a second 500M logical volume, lvfiles, to the group that lvdata belongs
- Put an ext4 filesystem on lvfiles and mount it persistently to /mounts/lvfiles

Knowledge Check
1. If a volume group contains 1 physical volume of size 1G, is it possible to
  create a logical volume of size 1G in that group? Why or why not?

:::details Answer
1. No. One extent will be used for metadata in the logical volume. If it is
   specified that the logical volume should be 1G (255 extents), then the
   underlying physical volume needs at least 256 extents. So create a physical
   volume slightly larger than 1G, eg 1028M, for a logical volume of exactly 1G.

:::


## Lab Exercise: Stratis
To perform these tasks, attach a 20G disk to your lab virtual machine
- Create a 10G stratis pool with the attached disk, spool, containing 3 filesystems:
  files, programs, and stuff
- Mount these filesystems persistently on /mounts/files, /mounts/programs/, and
  /mounts/stuff
- Copy all files from /etc/ that have a name starting with b, c, or g to
  /mounts/files
- Create a snapshot of the files filesystem
- Delete all files from /mounts/files
- Verify that you can still access these files from the snapshot
