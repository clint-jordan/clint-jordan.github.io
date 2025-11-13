---
title: "Initial VM Setup for RHCSA"
slug: "rhcsa-init"
tags: [linux, rhcsa]
published: 2025-10-29T14:12:42+00:00
updated: 2025-11-01T06:58:40+00:00
feature: false
draft: false
---

## Disable screen saver
This is mainly for working with virtual machines in practice. From GNOME:
Settings -> Power -> Power Saving -> Set to Never

## Swap caps and escape
```bash
gsettings set org.gnome.desktop.input-sources xkb-options "['caps:swapescape']"
```

## Set vim mode
```bash
echo "set editing-mode vi" >> ~/.inputrc
echo "set -o vi" >> ~/.inputrc
```


## Set aliases
```bash
echo "alias vi=vim" >> .bashrc
exec $SHELL
```

## Enable reverse search
```bash
echo '"\e[A": history-search-backward' >> .inputrc
echo '"\e[B": history-search-forward' >> .inputrc
exec $SHELL
```

## Avoid repetitive password input
Enable NOPASSWD for wheel only for throw away virtual machines.
Create file in `/etc/sudoers.d` with `visudo /etc/sudoers.d/wheel`
```text
%wheel ALL=(ALL:ALL) NOPASSWD: ALL
```
In a 'real' environment, increase authentication token expiration to avoid
Create file in `/etc/sudoers.d` with `visudo /etc/sudoers.d/defaults`
repetitive password input.
```text
Defaults timestamp_type=global,timestamp_timeout=240
```

Ensure sudoers can be parsed if `visudo` was not used to create drop-in files.
```bash
visudo -cf /etc/sudoers
```

Set permissions of wheel file if `visudo` was not used and **!!!only if sudoers
file was successfully parsed!!!**
```bash
chmod 0440 /etc/sudoers.d/wheel
chmod 0440 /etc/sudoers.d/defaults
```

Logout or Reboot
