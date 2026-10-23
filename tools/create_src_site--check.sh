#!/bin/bash

# SPDX-FileCopyrightText: Robert Ryszard Paciorek <rrp@opcode.eu.org>
# SPDX-License-Identifier: MIT

for repo_name in *; do [ -d "$repo_name/.git" ] && (
	cd "$repo_name"
	github_org=$(git remote -v | grep 'pub-github.*' | awk '$3 ~ "push" {print $2}' | awk 'BEGIN {FS="[/:]"} $1=="ssh" {print $5; next} {print $2}')
	case "${github_org,,}" in
		"opcode-eu-org-website"|"opcode-eu-org-libs")
			mode="opcode"
			url="https://src-opcode.pages.dev/"
			;;
		"dragons-labs")
			mode="dragons-labs"
			url="https://src-dragons-labs.pages.dev/"
			;;
		*)
			#echo "no-pub $repo_name 0 1"
			exit
			;;
	esac
	LOCAL_HEAD=$(git rev-parse master)
	REMOTE_HEAD=$(git ls-remote "$url/$repo_name" | awk '$2=="HEAD" {print $1}')
	echo "$mode $repo_name $LOCAL_HEAD $REMOTE_HEAD"
); done | sort | awk '
	$3 != $4 {print $0}
'
