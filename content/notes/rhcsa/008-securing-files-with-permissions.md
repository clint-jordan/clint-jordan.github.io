---
title: "Securing Files with Permissions"
tags: [linux, rhcsa]
published: 2025-11-01T09:20:20+00:00
feature: false
draft: true
---

## Changing File Ownership

Change user and optionally group ownership
```bash
chown user[:group] file
```

Change group ownership only
```bash
chgrp group file
```

Change file permissions
```bash 
chmod 
```

## Basic Permissions
| Permission     | File          | Directory             |
|----------------|---------------|-----------------------|
| read (r/4)     | read          | list contents         |
| write (w/2)    | modify        | add/remove files      |
| execute (x/1)  | run file      | cd into directory     |

## Common Permission Combinations

| Octal | Permissions | Description           |
|-------|-------------|-----------------------|
| 644   | rw-r--r--   | Owner read/write, others read |
| 755   | rwxr-xr-x   | Owner full, others read/execute |
| 600   | rw-------   | Owner read/write only |
| 777   | rwxrwxrwx   | Full permissions for all |

## Special x
When x is applied recursively, it makes directories as well as all files
executable. This is generally not the desired result. In recursive commands, use
X instead.
- Directories will be granted the execute permission
- Files will only get the execute permission if it is already set elsewhere on
  the file

## Managing Basic Permissions
Absolute mode (digits contain all permissions information)
```bash
chmod 750 file
```

Relative mode (quickly set a single permission)
```bash
chmod u+x file
```

## Applying Default Permissions
Default permissions are 666 for files and 777 for directories, but the umask is
subtracted, which essentially allows you to change the default permissions. The
default umask is 022, which produces 644 for files and 755 for directories.

```bash
umask 027
```

This would produce 640 for files and 750 for directories. Changing the umask is
very rarely a good idea, so don't do it.

## Configuring Shared Group Directories
The Set Group ID (SGID) permission ensures that all files created in the shared
group directory are group owned by the group owner of the directory.

Add SGID in relative mode.

```bash
chmod g+s groupdir 
```

Add SGID in absolute mode (the first digit, 2, is the SGID permission)
```bash
chmod 2770 groupdir 
```

The sticky bit permission ensures that only the user who is owner of the file,
or the directory that contains the file, is allowed to delete the file.

Add sticky bit in relative mode.

```bash
chmod +t groupdir
```

Add sticky bit in absolute mode (the first digit, 1, is the sticky bit permission)
```bash
chmod 1770 groupdir 
```

Add both SGID and sticky bit in absolute mode
```bash
chmod 3770 groupdir 
```

The Set User ID (SUID) ensures that a program file is executed with the
permissions of the owner. Use cases for this are very rare, as most files are
owned by root!

## Lab Exercise
- Create a shared group directory structure /data/profs and /data/students that
  meets the following conditions:
  - Members of the groups have full read and write access to their directories,
    others have no permissions at all
- Print a list of all files that have the SUID permission set

In the solution, Sander van Vugt said no SGID or sticky bit information was
specified, so neither of them should be created. On the exam, do not assume
anything! Only perform tasks that are explicitly required.

Follow Up:
- Users of the shared directories profs and students should not be able to
  delete files or directories owned by other users