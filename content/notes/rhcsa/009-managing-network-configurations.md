---
title: "Managing Network Configurations"
tags: [linux, rhcsa]
published: 2025-11-01T15:15:09+00:00
feature: false
draft: true
---

## IPv4 Networking
- In IPv4, each node needs its own IP address, written in dotted decimal
  notation (192.168.4.200/24)
- Each IP address must be indicated with the subnet mask behind it (/24 above)
- The default router or gateway specifies which server to forward packets to
  that have an external destination
- The DNS nameserver is the IP address of a server that helps to resolve to IP
  addresses and the other way around
- IPv4 is still the most common IP version, but IPv6 addresses can be used as
  well
- IPv4 and IPv6 can co-exist on the same network interface

## IPv6 Networking
- IPv6 was introduced in the 1990's to overcome the shortage of world-wide
  unique IPv4 addresses.
- IPv6 is used extensively by Internet Service Providers to address the core
  internet infrastructure
- End-users and companies mostly use IPv4 behind a NAT (Network Address
  Translation) router
- RHEL offers dual stack IPv4 and IPv6
- IPv6 addresses are 128-bit numbers, which are normally expressed as 8
  colon-separated groups of four hexadecimal numbers
- In these numbers, leading zeros are omitted
  - `2001:db:7891:123:1010:6bbd:cbcb:210`
- Long strings of zeros can be replaced by one block of two colon characters
- When combining an IPv6 address with a port number, enclose the IPv6 address in
  square brackets
- Subnets are largely irrelevant. IPv6 addresses have a standard subnet of 64 bits


| Purpose         | Example                  | Description                                          |
|-----------------|--------------------------|------------------------------------------------------|
| localhost       | ::1/128                  | Loopback address (equivalent to 127.0.0.1 in IPv4) |
| unspecified     | ::                       | Used to refer to all ip addresses                    |
| default route   | ::/0                     | IPv6 default route (equivalent to 0.0.0.0/0 in IPv4)|
| global unicast  | 2000::/3                 | IPv6 addresses currently being allocated            |
| unique local    | fd00::/8                 | Addresses for internal use like 192.168.0.0           |
| link local      | fe80::/10                | Non-routable auto assigned for internal use           |
| multicast       | ff00::/8                 | Multicast addresses                                  |

- Apart from manual allocation and DHCP, IPv6 supports Stateless Address Autoconfiguration (SLAAC)
- In SLAAC, a host sends a router solicitation to the ff02::2 multicast group to access all routers
- A router answers that request, sending all relevant information
- The host adds an automatically generated host ID to the network prefix to obtain a unique address
- To enable SLAAC in RHEL 10, install the radvd package 


## Understanding NIC Naming

- IP address configurations need to be connected to a specific network device (Network Interface Card)
- Use `ip link show` to see current devices, and `ip addr show` to check their configuration
- Every system has a `lo` (loopback) device, which is for internal networking
- Apart from that, you'll see the name of the real network device, which is presented as a BIOS name
  - Classical naming uses device names like eth0, eth1, etc
    - These device names don't reveal any information about physical device location
  - BIOS naming is based on hardware properties to give more specific information
    - em[1-N] for embedded NICs
    - eno[nn] alternative notation for embedded NICs
    - p&lt;slot&gt;p&lt;port&gt; for NICs on the PCI bus
  - If the driver doesn't reveal network device properties, classical naming is used

## Defining Host Names and Host Name Resolution


- The hostname is written to /etc/hostname
- To resolve hostnames /etc/hosts is used
  - 10.0.0.1.1 server2.example.com server2
- /etc/resolv.conf contains DNS client configuration
- The order of host name resolution is determined through /etc/nsswitch.conf

Set the server hostname
```bash
hostnamectl hostname rhel10
```

Add hostname to /etc/hosts for resolution
```text
127.0.0.1 localhost rhel10 rhel10.example.com
```

## Analyzing Network Configuration

- The `ip` tool can be used to manage all aspects of IP networking
- It replaces the legacy `ifconfig` tool, do not use it anymore
- Use `ip addr` to manage address properties
  - `ip addr add dev ens33 10.0.0.10/24`
- Use `ip link` to show link properties
  - `ip -s link` 
- Use `ip route` to manage route properties
  - `ip route show`
  - `ip route add default via 10.0.0.1`
- Any changes made with the ip command will not be persistent


## Network Manager

- NetworkManager is the systemd service that manages network configuration
- Configuration is stored in file /etc/NetworkManager/system-connections
  - Legacy files in /etc/sysconfig/network-scripts are still supported, but deprecated
- Different applications are available to interface with NetworkManager
  - `nmcli` is a powerful command line interface
  - `nmtui` offers a convenient text user interface
  - GNOME offers graphical tools as well
- In NetworkManager, devices are network interfaces
- Connections are collections of configuration settings for a device, stored in
  the configuration file in /etc/NetworkManager/system-connections
- Only one connection can be active for a device
- Permissions to modify settings in NetworkManager are applied through `dbus`
- Non-privileged users that are logged in on the console can change network settings
- Non-privileged users that are logged through ssh cannot change network settings
- Use `nmcli general permissions` for an overview of current permissions that apply

## Managing Network Configuration with `nmcli`

Note: this is a useful tool, but it will not be on the exam.

- `nmcli` has awesome tab completion
- `nmcli con show` shows current connections
- `nmcli dev status` shows current network devices
- `nmcli con show {con-name}` shows all connection settings
- `nmcli con mod` will modify connection settings: use tab completion!
- `nmcli con reload` will reload the modified connection

Adding a new connection is complex
```bash
nmcli con add con-name mynewconnection ifname ens33 ipv4.addresses 10.0.0.10/24 ipv4.gateway 10.0.0.1 ipv4.method manual type ethernet
```

- Use `ipv4.method manual` on connections that don't use DHCP
- Without this setting, a DHCP server will be contacted, even if static configuration has been set


## Managing Network Configuration with `nmtui`

- Use `nmtui` to save time on the exam

## Troubleshooting Networking

- Use `ping` to verify connectivity
  - `ping -c 4 archlinux.org` sends 4 packets then stops
- Use `ping6` to ping an IPv6 address
  - When using `ping6` on link-local addresses, you must include the NIC name in the command
    - e.g. `ping6 ff02::1%ens33`
- `ip route` prints the routing table
- `ip -6 route` shows the IPv6 routing table
- `tracepath example.com` shows the entire networking path
- `tracepath6 example.com` shows the entire IPv6 networking path
- `ss` is used to analyze socket statistics
  - `ss -tu`
  - `ss -tuna`
  - `ss -tunap`
- `netstat -tulnp`

## Lab Exercise
- Set the hostname for your server to rhcsaserver.example.com
- Set your server to a fixed IP address that matches your current network configuration
- Also set a second IP address 10.0.0.10/24 on the same network interface
- Enable host name resolution for your local server hostname
- Reboot and verify your network is still working with the new settings


