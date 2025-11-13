---
title: "Using Essential Tools"
tags: [linux, rhcsa]
published: 2025-10-29T17:18:01+00:00
feature: false
draft: true
---

## Search man pages
```bash
man -k {search-string}
```

## Filter for user commands
```bash
man -k {search-string} | grep 1
```

## Filter for admin commands
```bash
man -k {search-string} | grep 8
```

## Lab Exercise
- Locate the `man` page that shows how to set a password
- What man section contains admin commands?
- What man section contains user commands?
- What man section contains system calls?