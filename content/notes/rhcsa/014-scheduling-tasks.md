---
title: "Scheduling Tasks"
tags: [linux, rhcsa]
published: 2025-11-10T10:29:49+00:00
feature: false
draft: true
---

## Scheduling options
- Systemd timers are the primary solution for scheduling recurring jobs
- `crond` is an older scheduling solution which is still supported and a bit
easier to schedule custom tasks
- `at` is available to schedule non-recurring user tasks

## Systemd timers
- Systemd provides unit.timer files that go together with unit.service files
- When using systemd timers, the timer should be enabled/started, NOT the
service unit
- Systemd timers are often installed from RPM packages
- In the timer unit file, the `OnCalendar` option specifies when the service
should be started
- Systemd timers have been the default way for scheduling recurring services
since  RHEL 9

### Timer activation
- `OnCalendar=*:00/10` runs every 10 minutes
- `OnCalendar=2026-*-* 9:9,19,29:30` runs the service every day in 2026 at
  9:09:30, 9:19:30, and 9:29:30
- Use `OnUnitActivateSec` to start the unit a specific time after the unit was
  last activated
- Use `OnBootSec` or `OnStartupSec` to start the unit a specific time after
  booting
- Read `man 7 systemd.time` for specification of the time format to be used

## `cron`
- Cron is an old UNIX scheduling option
- It uses `crond`, a daemon that checks its configuration to run cron jobs
periodically
- Still on RHEL 10, `crond` is enabled as a systemd service by default
- The `crond` process checks its configuration every minute
- `/etc/crontab` is the main (managed) configuration file
- `/etc/cron.d` can be used for drop-in files
- User-specific cron jobs can be created using `crontab -e`
- The `/etc/crontab` file has a nice syntax example
- `/etc/cron.{hourly,daily,weekly,monthly}` can be used as a drop-in for scripts
  that need to be scheduled on a regular basis
  - `anacron` takes care of these jobs
  - They are executed on a regular basis, but not at a specific time
  - Configuration is in `/etc/anacrontab`

It's important to note that user cron jobs run even when the user is logged out,
but user level systemd timers do not by default. When a user needs to schedule
jobs when they aren't logged in, `cron` or `at` may be the best option

## `at`
- The atd service must be running to run once-only jobs using `at`
- Use `at {time}` to schedule a job
  - Type one or more job specs in the interactive shell
  - Use Ctrl-D to close the shell
- Use `atq` for a list of jobs currently scheduled
- Use `atrm` to remove jobs from the list

## Temporary files
- In the past, temporary files were created in the `/tmp` directory
- Without management, these files could stay around for a long time
- As a solution, the `/tmp` directory could be created on a RAM drive
- Nowadays, `systemd-tmpfiles` is started while booting and manages temp files
  and directories
- Functionality has been expanded to manage other files also
- It will create and delete tmp file automatically, according to the
  configuration files in the following locations:
  - `/usr/lib/tmpfiles.d`
  - `/etc/tmpfiles.d`
  - `/run/tmpfiles.d`
- `systemd-tmpfiles` works with related services to manage temporary files
- `systemd-tmpfiles-setup.service` creates and removes temp files according to
  the configuration
- `systemd-tmpfiles-clean.timer` calls the `systemd-tmpfiles-clean.service` to
  remove temp files
  - By default 15 minutes after booting and also daily

- `d /run/myfiles 0750 root root` will create the directory /run/myfiles if
necessary. No action if it already exists
- `D /run/myfiles 0750 root root 1d` will create the directory /run/myfiles if
and wipe its contents if it already exists. Files older than 1 day are eligible
for automatic removal the next time `systemd-tmpfiles` runs
- `man tmpfiles.d` provides detailed information and examples

## Lab Exercise
- Ensure the systemd timer that cleans up tmp files is enabled
- Run a cron job that will issue the command `touch /tmp/cronfile` 5 minutes
  from now as user linda
- Use `at` to schedule a job to power off your system at a convenient time later
  today




