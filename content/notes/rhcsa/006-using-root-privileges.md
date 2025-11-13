---
title: "Using root Privileges"
tags: [linux, rhcsa]
published: 2025-11-01T06:08:37+00:00
feature: false
draft: true
---

## Becoming root
The root user operates in 
[kernel space](https://en.wikipedia.org/wiki/User_space_and_kernel_space), which
it is best practice to not set a root password. If root is able to log in to a
graphical environment, everything running in that environment has root
privileges.

```bash
sudo -i
```

## Login as Another User
```bash
su - {user}
```

The `-` starts the shell as a login shell. This is useful for testing the
configuration of a user account. 

## Managing sudo Configuration

Add user to wheel group.
```bash
usermod -aG wheel {user}
```

Never enable NOPASSWD for wheel in a 'real' environment. Instead, increase the
authentication token expiration to avoid repetitive password input.

Set global authentication timeout.

```text
Defaults timestamp_type=global,timestamp_timeout=60
```

Set the authentication timeout to 60 minutes for user, somebody, only.
```text
Defaults:somebody timestamp_timeout=60
```

Always require a password from user, somebody, only.
```text
Defaults:somebody timestamp_timeout=0
```

Infinite timeout for user, somebody, only.
```text
Defaults:somebody timestamp_timeout=-1
```

Set the authentication timeout to 240 minutes for group, wheel, only.
```text
Defaults:%wheel timestamp_timeout=240
```

Do not require a password for user, somebody.
```text
Defaults:somebody !authenticate
```

Provide user, lisa, admin access to specific commands.
```text
lisa ALL=/sbin/useradd,/usr/bin/passwd
```

Allow group, users, to mount and unmount only the /dev/sdb device.
```text
%users ALL=/bin/mount /dev/sdb,/bin/umount /dev/sdb
```

Allow user, somebody, to set any user's password except root.
```text
somebody ALL=/usr/bin/passwd, ! /usr/bin/passwd root
```

## Lab Exercise
- Create a new user issac
- Allow issac to perform the following user management tasks
  - create, modify, and delete users
  - change passwords for all users except root
- Ensure that issac only needs to enter a password for admin operations every 60 minutes
- Ensure that the default authentication timeout for all users with sudo privileges is 30 minutes
- Ensure that the default authentication timeout for members of group wheel is 240 minutes

