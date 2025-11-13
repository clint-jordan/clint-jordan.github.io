---
title: "Managing Processes"
tags: [linux, rhcsa]
published: 2025-11-09T18:15:56+00:00
feature: false
draft: true
---

## Using signals to manage process state
- A signal allows the operating system to interrupt a process from software and
  ask it to do something
- Interrupts are comparable to signals, but are generated from hardware
- A limited number of signals can be used and is documented in `man 7 signals`
- Not all signals work in all cases
- The `kill` command is used to send signals to PIDs
  - Alternatively, you can use `k` from `top`
- Different kill-like commands exist, like `pkill` and `killall`

## Priority management
- Linux Cgroups provide a framework to apply resource restrictions to Linux
  systems
- Cgroups can limit the amount of CPU cycles, available memory, and more
- If processes are equal from a perspective of Cgroups, the Linux `nice` and
  `renice` commands can be used to manage priority

Note: for RHCSA, only `nice` and `renice` is needed

- In Cgroups, the Linux system is divided in 3 slices
  - System: all systemd processes
  - User: all user processes
  - Machine: virtual machines and containers
- Each slice has an equal CPU weight
  - So 20 systemd processes together gets as much as one user process that
    claims full CPU usage!
- In systemd, the CPUWeight can be set on individual systemd units

- If no specific Cgroups are defined, Linux `nice` and `renice` can be used to
define CPU priority
- To change priorities of non-realtime processes, the `nice` and `renice` can be used
- `nice` values range from -20-19
- Negative `nice` value indicates an increased priority, a positive `nice` value
  indicates decreased priority
- Users can set their processes to a lower priority; to increase priorities you
  need root access
 - `nice -n 19 dd if/dev/zero of=/dev/null`
 - Priority is always relative to other processes


## Using tuned profiles
- Kernel tunables are provided through the `/proc/sys` directory in the `/proc`
pseudo file system
- Different files in the `/proc/sys` directory contain the current setting as
its value
- Change the current value by echoing a new value into the file
  - `cat /proc/sys/vm/swappiness`
  - `echo 40 > /proc/sys/vm/swappiness`
- To make settings persistent, write them to a file in `/etc/systctl.d`
```
cat >> swappiness.conf << EOF
vm.swappiness = 40
EOF
```

- To make system tuning easier, `tuned` is provided
- `tuned` is a systemd service that works with different profiles
- `tuned-adm list` shows current profiles
- `tuned-adm profile virtual-guest` sets another profile as default
- Each profile contains a file with the name tuned.conf that has a wide range of
  performance related settings
- The `reapply_sysctl=1` parameter in `/etc/tuned/tuned-main.conf` ensured that,
  in case of conflict, the `sysctl` parameter wins

## Managing user sessions and processes
- `ps -u username` to show processes owned by a specific user
- `pkill -u username` to remove processes owned by a specific user

- `loginctl` is a part of systemd, which manages users and sessions
- `loginctl list-users` and `loginctl list-sessions` shows users and sessions
- `loginctl user-status {UID}` shows a tree of processes currently opened by
  this user
- `loginctl terminate-session` and `loginctl terminate-user` can be used to stop
  current sessions or users


## Lab Exercise
- Create a user linda and open a shell as this user
- As linda, run two background processes `sleep 600`, one of them with the
highest possible priority, the other one with the lowest possible priority
- Use the most efficient way to terminate all current sessions for user linda

