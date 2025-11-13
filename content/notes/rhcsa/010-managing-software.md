---
title: "Managing Software"
tags: [linux, rhcsa]
published: 2025-11-03T14:08:28+00:00
updated: 2025-11-08T16:24:39+00:00
feature: false
draft: true
---

## DNF and Flatpak Use Cases

RPM, YUM, and DNF
- In the early days, software was packaged as a tarball, and installing meant
  extracting the tarball and do as directed
- Red Hat Package Manager (RPM) introduced packages on Red Hat
- These packages contained metadata with information about required dependencies
  - A database was also added to keep track of installed packages, which made
    updating software easier
  - Still, dependencies needed to be resolved manually
- When Yellowdog Update manager (YUM) was introduced, packages could be
  installed from repositories, and dependencies could be handled automatically
- Dandified Yum (DNF) was mainly an internal improvement of YUM, and still used
  the same approach for installing packages
- Still in DNF, packages need to be created for specific linux OSs and
  architecture

Flatpak
- Flatpak is attempting to resolve the lack of package management
  standardization between distributions by providing images that run isolated as
  a container on most linux distributions and architectures
- The image contains everything required to run the package
- A Flatpak application runs in a sandbox, which isolates it from other system
  components by default

When to use which?
- Flatpak is excellent for desktop applications
- DNF is preferred for server processes and daemons that need tight integration
  with the server operating system

## Managing RPM Packages
- Software on RHEL is installed using packages in Red Hat (RPM) format
- An RPM package contains a compressed archive and package metadata
- In the metadata, package dependencies are identified
- To automatically handle dependency management, RHEL uses `dnf` and
  repositories for package installation
- Packages  should not be installed with `dnf`, not `rpm`
- Installed packages are registered in the RPM database
- The `rpm` command can be used to list packages and analyze package content
  - `rpm -qa` shows all packages currently installed
  - `rpm -qf filename` shows from which package filename was installed
  - `rpm -ql` lists files installed from a package
  - `rpm -q --scripts` shows scripts executed while installing the package
  - `rpm -q --changelog` shows the changelog for a package
- Querying package files rather than the RPM database is also possible
  - Add `-p` to any of the commands above
- Contents of an RPM package can be extracted to the current directory (without installing)
  - `rpm2cpio mypackage.rpm | cpio -tv` will show the contents of a package
  - `rpm2cpio mypackage.rpm | cpio -idmv` extracts the package contents to the current directory

### Exercise
- Determine what package the file `/etc/crypttab` comes from
- List the other files created from that package
- List the configuration files associated with that package

### `rpm` Solution
```bash
rpm -qf /etc/crypttab
rpm -ql systemd-udev
rpm -qc systemd-udev
```
### `dnf` Solution
Search both installed packages and repositories
```bash
dnf provides /etc/crypttab
```
Query an existing file
```bash
dnf repoquery -f /etc/crypttab
```
List all installed package files
```bash
dnf repoquery --installed -l systemd-udev
```
List all files in `/etc`. Note that not all these are configuration files, thus,
`rpm -qc` is a better method.
```bash
dnf repoquery --installed -l systemd-udev | grep -E '^/etc/'
```

## Setting up Repository Access
- A repository is a collection of RPM package files with an index that contains the repository contents
- Repositories are often offered through websites, but local repositories can be created also
- The `dnf` command is used as the default command to install packages from repositories
- In RHEL 10, `dnf` is preferred over the `yum` command

- To access repositories, a RHEL system should be registered using `subscription-manager`
- `subscription-manager` tries to access the online Red Hat repositories
- As an alternative to online repositories, repos can be offered through Red Hat Satellite
- If not internet connection, nor Red Hat Satellite are available, no repos will be available by default
- In that case, you will have to manually configure repo access

- To ensure packages have not been tampered with, GPG keys can be used
- A repo GPG key is used to sign all packages and before installing the package, its signature is checked
- To do this, you'll need a local GPG key to be present
- To make accessing trusted repos easier, use the `gpgcheck=0` option in the repo client file
  - This option is acceptable, and may be required, on the exam
- To access repositories that are offered through subscription manager, use `dnf config-manager --enable repo-name`

Third party repos can be added using a repo file in `/etc/yum.repos.d/`, or using `dnf config-manager`

In the video, Sander Van Vugt clones the virtual machine to an iso file using dd
and mounts the iso to /repo. This is essentially used as a repository 'server'.

```bash
dnf config-manager --add-repo="file:///repo/BaseOS"
dnf config-manager --add-repo="file:///repo/AppStream"
```

Then add `gpgcheck=0` to each of the repo files in `/etc/yum.repos.d`

or

```bash
cat >> /etc/yum.repos.d/AppStream.repo << EOF
[AppStream]
name=AppStream
baseurl=file:///repo/AppStream
gpgcheck=0
EOF
```

## Managing packages with `dnf`

- `dnf list` lists installed and available packages
  - `dnf list 'selinux*'`
- `dnf search` searches name and summary `dnf search all` searches in description as well
    - `dnf search seinfo`
    - `dnf search all seinfo`
- `dnf provides` searches in package file lists for the package that provides a specific file
  - `dnf provides */Containerfile` will list all packages that have a file Containerfile 
- `dnf info` shows information about a package
- `dnf install` installs packages as well as any dependencies
- `dnf remove` removes packages as well as dependencies
- `dnf update` compares current package version with the package version listed
  in the repository and updates if necessary
  - `dnf update kernel` will install the new kernel and keeps the old as a backup

## Using `dnf` groups
- A `dnf` group is a collection of packages
- A regular group is just a collection of packages
- An environment group is used to install a specific usage pattern, and may
  consist of packages and groups
- Use `dnf group list` to see a list of groups
- Some groups are normally only installed through environment groups and not
  separately, and for that reason don't show in `dnf group list`
- `dnf group info` to see packages within a group
- `dnf group install` to install only mandatory and default packages
  - `dnf group install --with-optional` to install optional as well

## Managing `dnf` updates and history
- `dnf history list` lists `dnf` transactions
- `dnf history undo` to undo a transaction from the list (AMAZING)
- `dnf history --help` for a list of options

## Subscription Manager
DO NOT DO THIS FOR PRACTICE VMs
- To register, use `subscription-manager register`
- To unregister, use `subscription-manager unregister`
  - After registering, entitlement certificates are created
    - `/etc/pki/product` indicates the installed Red Hat products
    - `/etc/pki/consumer` identifies the Red Hat account for registration
    - `/etc/pki/entitlement` indicates which subscription is attached
- Use `rct` to check current entitlements

## Flatpak 'remotes'
- To get access to the default Flatpak repository, you must authenticate using
  podman login registry.redhat.io
- To make the login persistent for the current user, use the following command:
  - `cp $XDG_RUNTIME_DIR/containers/auth.json $HOME/.config/flatpak/oci-auth.json`
- Flatpak uses remote repositories ("remotes") to install packages
- Remotes are stored in `/etc/flatpak/remotes.d`
- Red Hat has its own remote repository, otherwise the repository at
  https://flathub.org is commonly used
- Use `flatpak remotes` to print a list of the remote repositories that are available
- To add a remote, use `flatpak remote-add --if-not-exists fedora oci+https://registry.fedoraproject.org`
  - `flatpak remote-add --if-not-exists {remote-name} {remote-url}`
- `flatpak remotes --system` lists remotes available to everyone
- `flatpak remotes --user` lists remotes available to this user only
- `flatpak remote-ls {remote}` lists applications available in the remote repository


## Managing Flatpak applications
- `flatpak search`
- `flatpak install`
  - `flatpak install -u` to install an application for the current user only
- `flatpak list` shows applications currently installed
- `flatpak info`
- `flatpak update`
- To ensure that an application won't be updated, use `flatpak mask`
  - Use `flatpak mask --remove` to remove the mask
- `flatpak uninstall [--delete-data]` uninstalls and optionally deletes application data

## Setting up offline repo 
Note: This is for the lab environment only, not required for the exam.

On virtual machine host:
```bash
scp -P 2222 rhel-10.0-x86_64-dvd.iso cjordan@localhost:~
```

On virtual machine (as root):
```bash
mv /home/cjordan/rhel-10.0-x86_64-dvd.iso /repo.iso
cp /etc/fstab /etc/fstab.bak
echo "/repo.iso /repo iso9660 defaults 0 0" >> /etc/fstab
mount -a
```


## Lab Exercise
- Ensure your system is using an offline repository for base packages as well
  as application streams
- Find the package that contains the `seinfo` program file and install it
- Install Firefox as a flatpak application
