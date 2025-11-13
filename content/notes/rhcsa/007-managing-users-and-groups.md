---
title: "Managing Users and Groups"
tags: [linux, rhcsa]
published: 2025-11-01T07:30:25+00:00
feature: false
draft: true
---

## User Properties

[Fedora Docs](https://docs.fedoraproject.org/en-US/fedora/f40/system-administrators-guide/basic-system-configuration/Managing_Users_and_Groups/)

Knowledge Check
- Where are user properties managed?
- Where are user password properties managed?

<!-- Answer -->
<!-- - User properties are managed in /etc/passwd and /etc/shadow -->
<!--   - `/etc/passwd` contains basic -->
<!--     - Name: name of the account -->
<!--     - Password: authentication secret, may be disabled -->
<!--     - UID: a unique identifier for users -->
<!--     - GID: ID of the primary group -->
<!--     - GECOS: additional non-mandatory information about the user -->
<!--     - Home directory: environment where users create personal files -->
<!--     - Shell: the program that will be started after successful authentication -->
<!--   - /etc/shadow -->
<!--     - Username -->
<!--     - Password -->
<!-- 		- Last password change -->
<!-- 		- Minimum - minimum days between password changes -->
<!-- 		- Maximum - maximum days password is valid -->
<!-- 		- Warn - number of days before expiration that the user is warned  -->
<!-- 		- Inactive - days after expiration that the user is disabled -->
<!-- 		- Expire - expiration date of account (expressed as days since Jan 1, 1970) -->

## Create and Manage Users
- useradd: add a user
- usermod: modify a user
- userdel: delete a user
- passwd: change a user password

### Defining defaults

- Write default settings to /etc/login.defs
- Files in /etc/skel are copied to the user home directory upon creation.
- RHEL 10 uses Pluggable Authentication Modules (PAM) which is used to define
  more advanced default settings (not RHCSA topic). See `authselect`.

### Limit user access
Lock user account, anna
```bash 
usermod -L anna
```

Unlock user account, anna
```bash 
usermod -U anna
```

Set expiration date for user account, bill
```bash
usermod -e 2032-01-01 bill
```

Set shell to `/sbin/nologin` for a user, application, that is not intended to
login at all
```bash
usermod -s /sbin/nologin application
```

### Managing group access

Knowledge Check
- Explain the difference between primary and secondary groups
- Where are primary groups managed?
- Where are secondary groups managed?
- How can you temporarily change the primary group?
- How can you print all the groups that a user is a member of?

<!-- Answers -->
<!-- - For filesystem permission purposes, each user must be a member of at least one group -->
<!-- - Primary group membership is managed through /etc/passwd -->
<!-- - The user primary group becomes group-owner if a user creates a file -->
<!-- - Secondary group membership is managed through /etc/group -->
<!-- - Temporarily set primary group membership using `newgrp` -->
<!-- - Use `id` to see which groups a user is a member of -->

## Creating and Managing Groups

- groupadd: add a group
- groupmod: modify a group
- groupdel: delete a group


Create a new group, support-desk
```bash
groupadd support-desk
```

Add user, somebody, to group, support. Without `-a` (append) the current list of
groups would be overwritten.
```bash
usermod -aG support somebody
```

Find all members of a group, support
```bash
grep support /etc/group
```

### Managing password properties

Set password age properties for user, somebody
```bash
chage somebody
```

## Lab Exercise
- Ensure that new users are required to reset their passwords every 90 days
- Ensure that all new users get an empty file, newfile, created in their home directory
- Create users andrew, peter, sally, and susan
- Set the passwords for andrew and sally, but disable the passwords for peter and susan
- Create the groups engineers and designers. Make andrew and sally members of engineers.
  Make peter and susan members of designers.

