---
title: "Configuring Logging"
tags: [linux, rhcsa]
published: 2025-11-11T09:29:32+00:00
feature: false
draft: true
---

## RHEL 10 logging options

References
- [Fedora Project Docs](https://docs.fedoraproject.org/en-US/fedora/f40/system-administrators-guide/monitoring-and-automation/Viewing_and_Managing_Log_Files/)

Knowledge Check
- Where does the systemd journal receive log messages from?
- By default, are systemd journal logs persistent or non-persistent?
- Where does the rsyslog service write log messages to by default?
- How can you modify where rsyslog writes logs?

<!-- Answers
- systemd-journald receives log messages from:
  - the kernel
  - boot procedures
  - syslog events
  - STDOUT and STDERR from daemons
- The systemd journal is non-persistent by default
- The rsyslog service reads syslog messages and writes them to files in
  `/var/log` or as defined in an output module
- Services may also write to `/var/log` -->

## Using systemd-journald

References
[Fedora Project Docs](https://docs.fedoraproject.org/en-US/quick-docs/viewing-logs/)

Useful commands
```bash
systemctl status name.unit # easy access to the latest log messages
journalctl # prints entire journal (important in red)
journalctl -p err # shows only messages with a priority error and higher
journalctl -f # shows the last 10 lines and follows
journalctl -u name.unit # 
journalctl --since "-1 hour"; journalctl --since today 
journalctl -o verbose # 
journalctl -b # shows current boot log
journalctl -xb # add explanation to boot log messages
journalctl --list-boots # shows all boots that have been logged (persistent journal only)
journalctl -b 3 # shows messages from the third boot log only
```

## Preserving the systemd journal

Knowledge Check
1. Why are systemd logs non persistent by default?
1. Where are the systemd journal settings?
1. How can you make systemd logs persistent?
1. What are the storage options for the systemd journal?
1. How often are log files rotated by default?
1. How much of the filesystem size can be used by logs by default?
1. How much of the filesystem free size can be used by logs by default?

:::details Answers
1. Persistent logs are handled by the rsyslog service
1. /usr/lib/systemd/journal.conf
1. If Storage=auto (the default), create the /var/log/journal directory and
   flush the journal
1. Storage options
   - auto: will write persistent logs to /var/log/journal if the directory
     exists, otherwise will write volatile logs to /run/log/journal
   - persistent: stores journals in /var/log/journal
   - volatile: stores journals in the temp /run/log/journal directory
   - none: doesn't use any storage for the journal at all
1. Log files are rotated monthly by default
1. 10%
1. 15%

:::

```bash
journalctl | grep -E 'Runtime Journal|System Journal' # check current settings
```

Make the system journal logs persistent
```bash
grep 'Storage=' /usr/lib/systemd/journal.conf
mkdir /var/log/journal
systemctl restart systemd-journal-flush.service
ls /var/log/journal
```

## Rsyslog
Knowledge Check
- Where is the configuration file for rsyslog?
- How should you modify the rsyslog configuration?
- What does each logger line contain?
- Where are log files normally located?

:::details Answers
1. /etc/rsyslog.conf
1. Add drop-in files to /etc/rsyslog.d
1. Each logger line contains
   - facility
   - severity
   - destination
1. /var/log

:::


## Logrotate

Knowledge Check
1. Where are the log rotate configuration files

:::details Answers
1. /etc/logrotate.conf and /etc/logrotate.d

:::

## Lab Exercise
1. Make sure the systemd journal is persistent
1. Create an entry in rsyslog that writes all messages with a severity of error
   or higher to /var/log/error
1. Ensure that /var/log/error is rotated on a monthly basis, and the last 12
   logs are kept before they are rotated out

:::details Solution
#### Make sure the systemd journal is persistent
```bash
mkdir /var/log/journal
systemctl restart systemd-journal-flush.service
```
or
```bash
mkdir /var/log/journal
journalctl --flush
```

#### Create an entry in rsyslog
```bash
echo "*.err /var/log/error" > /etc/rsyslog.d/error.conf
systemctl restart rsyslog
logger -p err "error message"
tail /var/log/error
``````

#### Add logrotate rule
/etc/logrotate.d/error.conf
```text
/var/log/error {
  monthly
  rotate 12
}
```

:::
