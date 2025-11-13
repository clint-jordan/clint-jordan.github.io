---
title: "Working with Systemd"
tags: [linux, rhcsa]
published: 2025-11-10T05:41:07+00:00
feature: false
draft: true
---

## The role of systemd
- Systemd is started as the first process after loading the kernel and is the
  manager of everything
- The items started by systemd are referred to as units
- `systemctl` is the main management tool for systemd
- `systemctl -t help` prints an overview of all types of units that are
  available
- `systemctl list-units` prints an overview of all units that systemd starts

## Systemd units
- Service units are used to start processes
- Socket units monitor activity on a port and start the corresponding service
  unit when needed
- Timer units are used to start services periodically
- Path units can start service units when activity is detected in the file
  system
- Mount units are used to mount file systems
- Other unit types are available, though less relevant for RHCSA
  - Service units are the most important for RHCSA

- Service units are often used to start daemon processes (processes that run all
the time)
- Anything can run through systemd (Type=simple)

Useful commands:
```bash
systemctl list-units
systemctl list-unit-files
systemctl list-units --type=service --state=running
```

## Managing systemd services

Useful commands:
```bash
systemctl status {service}
systemctl restart {service}
systemctl enable {service}
systemctl disable {service}
systemctl daemon-reload
```

## Modifying systemd unit configuration
- Default system-provided systemd unit files are in `/usr/lib/systemd/system`
- Custom unit files are in `/etc/systemd/system`
- Run-time auto-generated unit files are in `/run/systemd`
- Do NOT edit files in `/usr/lib/systedmd/system`, instead create overlays in
  `/etc/systemd/system`
- Even better: use `systemctl edit {unit}.service` to edit unit files and drop
  in file will be created
- Use `systemctl show` to show available parameters

Useful commands:
```bash
systemctl show
systemctl daemon-reload
man systemd.directives
systemctl edit {unit}.service
```

## Managing unit dependencies
- Systemd units normally depend on other units
- Use `systemctl list-dependencies` for a complete overview of all currently
loaded units and their dependencies
- Use `systemctl list-dependencies {unit}` to see dependencies for any unit

Add dependencies in the Unit section of service files. Example:

```bash
systemctl edit httpd
```
```
[Unit]
Requires=vsftpd.service
```
Now systemd will attempt to start `vsftpd` before `httpd`.

## Masking services
- Some units cannot work simultaneously on the same system (for example, two
  different web servers)
- To prevent administrators from accidentally starting these units, use
  `systemctl mask`
- `systemctl mask` links a unit to the `/dev/null` device, which ensures that it
  cannot be started
- `systemctl unmask` removes the mask

```bash
systemctl mask nginx.service
systemctl start nginx.service
```


## Using systemd to run anything
Example service
```
[Unit]
Description="sleepy service"

[Service]
Type=simple
ExecStart=/usr/bin/sleep infinity

[Install]
WantedBy=multi-user.target
```

## Lab Exercise
- Ensure the httpd service is automatically started
- Edit its configuration such that on failue, it will restart after 1 minute
- Ensure that an nginx service cannot be started on this machine
