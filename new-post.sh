#!/usr/bin/bash
set -euo pipefail
IFS=$'\n\t'

showHelp() {
    echo "Usage:" 
    echo -e "  $0 [opt] <filename>"
    echo "Options:"
    echo "  -b, --blog    Create a blog post"
    echo "  -n, --note    Create a note"
    echo "  -p, --project Create a project"
    echo "  -u, --update  Update post timestamp"
    echo "  -h, --help    Show this help message"
    exit 1
}

if [ $# -eq 0 ]; then
    showHelp
elif [ $# -gt 2 ]; then
    echo -e "\033[31mError: Too many arguments\033[0m"
    showHelp
fi

rootDir=$(dirname "$0") 

getPrefix() {
    latest=$(find $contentDir -type f -name "*.md" | xargs -I {} basename {} | sort -r | head -n 1 | cut -d "-" -f 1)
    # Remove leading zeros to force decimal interpretation
    latest=${latest##0}
    # Handle case where all digits were zeros
    [ -z "$latest" ] && latest=0
    printf "%03d" $((10#$latest + 1))
}

getTimestamp() {
    date +"%Y-%m-%dT%H:%M:%S+00:00"
}

updatePost() {
    f=$rootDir/$1
    if [[ ! -f "$f" ]]; then
        echo "Error: post "$f" not found"
        exit 1
    fi
    stampRegex='[0-9]*-[0-9]*-[0-9]*T[0-9]*:[0-9]*:[0-9]*.[0-9]*:[0-9]*'
    if ! grep -q "^updated:.*$stampRegex" "$f"; then
        sed -i "/^published:.*$stampRegex/a\updated: $(getTimestamp)" "$f"
    else
        sed -i "s|^updated:.*$stampRegex|updated: $(getTimestamp)|" "$f"
    fi
}


short=b:,n:,p:,u:,h
long=blog:,note:,project:,update:,help
opts=`getopt \
    --options $short \
    --long $long \
    --name $( basename "$0" ) \
    -- "$@"`
if [ $? != 0 ] ; then echo "Failed parsing options." >&2 ; exit 1 ; fi

eval set -- "$opts"

# printf "%s \n" ${opts[*]}

while (( $# )); do
  case "$1" in
    -b | --blog ) contentType=blog; shift; name=$1; shift ;;
    -n | --note ) contentType=note; shift; name=$1; shift ;;
    -p | --project ) contentType=project; shift; name=$1; shift ;;
    -u | --update ) shift; updatePost $1; exit 1 ;;
    -h | --help ) showHelp; exit 1 ;;
    -- ) break ;;
    * ) break ;;
  esac
done

#   title: z.string(),
#   slug: z.string().optional(),
#   description: z.string().optional(),
#   longDescription: z.string().optional(),
#   cardImage: z.string().optional(),
#   tags: z.array(z.string()).optional(),
#   feature: z.boolean().default(false),
#   hide: z.boolean().default(false),
#   draft: z.boolean().default(true),
#   isIndex: z.boolean().default(false),
#   indexDirectory: z.string().optional(),
#   published: z.date().transform((val) => new Date(val)).optional(),
#   updated: z.date().transform((val) => new Date(val)).optional(),

frontmatter="---
title: \"\"
description: \"\"
slug: \"\"
longDescription: \"\"
cardImage: \"\"
tags: []
published: $(getTimestamp)
feature: false
draft: true
---"

if [ $contentType = blog ]; then
    echo "--- creating blog post $name ---"
    contentDir=$rootDir/content/blogs
fi

if [ $contentType = note ]; then
    echo "--- creating note $name ---"
    contentDir=$rootDir/content/notes
fi

if [ $contentType = project ]; then
    echo "--- creating project $name ---"
    contentDir=$rootDir/content/projects
    frontmatter=$(echo "$frontmatter" | sed '/^tags:/a\repoUrl: ""' | sed '/^tags:/a\demoUrl: ""')
fi

prefix=$(getPrefix)
f="$contentDir/$prefix-$name.md"
echo "--- file: $f ---"
echo "$frontmatter" > $f
