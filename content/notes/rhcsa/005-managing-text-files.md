---
title: "Managing Text Files"
tags: [linux, rhcsa]
published: 2025-10-31T14:46:54+00:00
feature: false
draft: true
---

## Viewing file contents
Use `less` %99.9 of the time
```bash
less {file}
```

```bash
{command} | less
```

Display last 10 lines with `tail`
```bash
tail -n 10 {file}
```

Display first 10 lines with `head`
```bash
head -n 10 {file}
```

Display 10th line from the bottom with `head` and `tail`
```bash
tail -n 10 {file} | head -n 1
```

## `cut`, `sort`, `tr`
Extract the first field delimited by ':' from a file
```bash
cut -d ':' -f 1 /etc/passwd
```

Extract the first field delimited by ':' from a file and sort
```bash
cut -d ':' -f 1 /etc/passwd | sort
```

Sort numerically (-n) based on the third field/key (-k3) delimited by ':' (-t :)
```bash
sort -t : -k3n /etc/passwd
```

Translate `tr` lowercase to uppercase
```bash
echo hello | tr [:lower:][:upper:]
```

## Using `grep`

Show matches and include 5 lines before
```bash
ps faux | grep -B5 bash
```

Show matches and include 5 lines after
```bash
ps faux | grep -A5 bash
```

Show matches and include 5 lines before and after
```bash
ps faux | grep -C5 bash
```

Search in all files in a directory
```bash
grep cjordan /etc/*
```

Search in all files in a directory and output files, not lines
```bash
grep -l cjordan /etc/*
```

Case insensitive search in all files in a directory
```bash
grep -i cjordan /etc/*
```

Recursive search and follow all symbolic links
```bash
grep -R cjordan /etc
```

Recursive search and follow all symbolic links only if they are on the command line
```bash
grep -r cjordan /etc
```

Prefix results with line number
```bash
grep -n cjordan /etc/*
```

## Applying Regular Expressions
- Always put regex between single quotes
- Regex is not the same as globbing
- For use with specific tools only (grep, vim, awk, sed)
- Use of extended regular expressions must be specified with `grep -E`

Regex man page
```bash
man 7 regex
```

- `^` beginning of the line: `grep '^|' myfile`
- `$` end of the line: `grep 'anna$' myfile`
- `\b` end of word: `grep '^lea\b' myfile` will find lines starting with lea, but not with leanne
- `.` one character: `grep '^.$' myfile` will find lines with one of any character
- `*` zero or more times: `grep 'n.*x' myfile` will match any amount of characters between n and x
- `+` one or more times (extended): `grep -E 'bi+t' myfile` will match bit, biit, biiit, etc, but not bt
- `?` zero or one time (extended): `grep -E 'bi?t' myfile` will match bt or bit, but not biit 
- `\n{3\}` n occurs 3 times: `grep 'bon\{3\}nen' myfile` will match bonnnnen
- string must be a word: `grep '\banna\b' myfile`
- match on either option (extended): `grep -E 'foo|bar' myfile`

## Exploring `awk`
Extract the fourth field delimited by a colon
```bash
awk -F : '{ print $4 }' /etc/passwd
```

Extract the fourth field delimited by a colon that contains cjordan
```bash
awk -F : '/cjordan/ { print $4 }' /etc/passwd
```

Extract the last field delimited by a colon that contains cjordan
```bash
awk -F : '/cjordan/ { print $NF }' /etc/passwd
```

## Using `sed`
Print the 5th line
```bash
sed -n 5p {file}
```

Search and replace
```bash
sed 's|anna|otto|g' {file}
```

Search and replace modifying file in place
```bash
sed -i 's|anna|otto|g' {file}
```

Delete second line from file
```bash
sed -i -e '2d' {file}
```

Insert line after match (`a\` append)
```bash
sed -i "/^foo/a\bar" {file}
```

Insert line before match (`i\` insert)
```bash
sed -i "/^foo/i\bar" {file}
```

## Lab Exercise
- Use `head` and `tail` to display the 5th line of the file /etc/passwd
- Use `sed` to display the 5th line of the file /etc/passwd
- Create a file with the following contents:
```text
foo
bar
bing
bang
```
- Use `sed` to replace 'foo' with 'fooski'. Do not modify the file in place.
- Use `sed` to insert 'bob' on a separate line above 'bing'. Modify the file in place
- Use `sed` to insert 'joe' on a separate line below 'bob'. Modify the file in place
- Use `awk` to filter the last column out of `ps aux`
- Use `grep` to show the names of all files in /etc that have lines that contain 'root' as a word
- Use `grep` to show all lines from all files in /etc that contain exactly 3 characters
- Use `grep` to find all files that contain the string 'alex', but exclude 'alexander'