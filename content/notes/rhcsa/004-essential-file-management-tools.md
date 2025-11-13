---
title: "Essential File Management Tools"
tags: [linux, rhcsa]
published: 2025-10-31T12:59:02+00:00
feature: false
draft: true
---

## Filesystem Hierarchy Standard
[Filesystem Hierarchy Standard](https://refspecs.linuxfoundation.org/FHS_3.0/fhs/index.html)

```bash
man hier
```

## Finding Files

Look for binaries in `$PATH`
```bash
which grep
```

Find using name
```bash
find / -name "hosts"
```

Find using type and size
```bash
find / -type f -size +100M
```

Find using multiple parameters
```bash
find / -type f -size +100M
```

Embedding commands in find command
```bash
find /etc -exec grep -l student {} \; 2> /dev/null
```
Where `{}` refers to the results of the find command. `grep -l` outputs the
files that contain the search string rather than the lines. ` \;` ends the
embedded command, the leading space is required.

Embedding multiple commands
```bash
mkdir ~/find/results
find /etc -exec grep -l student {} \; -exec cp {} ~/find/results \; 2> /dev/null
```

Using `xargs` to execute commands
```bash
sudo find /etc -name '*' -type f | sudo xargs grep '127.0.0.1'
```
or
```bash
sudo sh -c "find /etc -name '*' -type f | xargs grep 127.0.0.1"
```
or
```bash
sudo bash -c "find /etc -name '*' -type f | xargs grep 127.0.0.1"
```

## Mounting Filesystems

List block devices
```bash
lsblk
```

Mount a block device
```bash
mount /dev/{device-name} /mnt
```

## Using Links
Hard link (second name that points to the same inode).
- Hard links must be on the same device
- Directories cannot be hard linked
```bash
ln {source} {destination}
```

Symbolic Link (points to a name)
```bash
ln -s {source} {destination}
```
- Always use absolute paths so link survives being moved
- Soft links can be on different devices than what they point to

## Archiving Files
`tar` -> tape archiver
- By default, it doesn't compress data

Archive multiple directories
```bash
tar -cvf archive.tar /home /etc
```

Show contents of an archive
```bash
tar -tvf archive.tar
```

Extract contents of an archive to the current directory
```bash
tar -xvf archive.tar
```

Compress with gzip
```bash
tar -czvf archive.tar.gz /home /etc
```

Compress with bzip2
```bash
tar -czvf archive.tar.bz2 /home /etc
```

Compress with xz
```bash
tar -cJvf archive.tar.xz /home /etc
```

Determine compression method, if any, of ambiguous extension
```bash
file archive.tar
```

## Using Compression

- gzip (-z) is still the most common compression utility (fastest)
- bzip2 (-j) better compression than gzip, but slower
- xz (-J) best compression, but much slower

## Lab Exercise
- Use `tar` to create a compressed archive of all files in the /etc and /opt directories
- List the contents of the new archive
- Create a symbolic link to the new archive in the /tmp directory
- Extract the archive contents into ~/tmp
- Remove the archive from your home directory. What happens to the symbolic link?
- Remove ~/tmp