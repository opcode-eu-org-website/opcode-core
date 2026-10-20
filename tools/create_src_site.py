#!/usr/bin/python3

# SPDX-FileCopyrightText: Robert Ryszard Paciorek <rrp@opcode.eu.org>
# SPDX-License-Identifier: MIT

# Created with Gemini AI, 2026

import sys
import os
import json
import urllib.request
import re
from pathlib import Path
from jinja2 import Template

def get_public_repos(org_name):
	url = f"https://api.github.com/orgs/{org_name}/repos?type=public&per_page=100"
	headers = {
		"User-Agent": "Python-GitHub-API-Script",
		"Accept": "application/vnd.github+json"
	}
	result = []

	try:
		while url:
			req = urllib.request.Request(url, headers=headers)
			url = None
			with urllib.request.urlopen(req) as response:
				repos = json.loads(response.read().decode())
				
				for repo in repos:
					name = repo.get("name", "")
					html_url = repo.get("html_url", "")
					
					if not name:
						print(f"Invalid name '{name}' for '{html_url}'", file=sys.stderr)
						continue
					
					result.append((name[0].upper()+name[1:], html_url))
				
				link_header = response.headers.get("Link")
				if link_header:
					links = re.findall(r'<([^>]+)>;\s*rel="next"', link_header)
					if links:
						url = links[0]
	
	except urllib.error.HTTPError as e:
		print(f"HTTP Error: {e.code} {e.reason}", file=sys.stderr)
		if e.code == 403 and "rate limit" in e.read().decode().lower():
			print("The GitHub API rate limit has been reached. Please try again later.", file=sys.stderr)
	except urllib.error.URLError as e:
		print(f"Connection ERROR: {e.reason}", file=sys.stderr)
	
	return result

def get_repos_sorted(arg):
	return sorted(get_public_repos(arg), key=lambda x: x[1])


HTML_TEMPLATE_HEAD = """<!DOCTYPE html>
<html>
<head>
	<meta charset="utf-8">
	<title>{{ title }}</title>
	<link rel="stylesheet" href="/index.css">
	<style>
		h2 {
			text-align: center;
			font-size: 24px;
			font-family: monospace;
			margin: 8px;
		}
		div.repo_name {
			padding: 8px 16px 8px 16px;
			font-weight: bold;
		}
		div.repo_links {
			display: inline-block;
		}
		div.repo_links > a {
			padding: 8px 8px 8px 8px;
		}
		div.section ul > li.repo_clone {
			display: block;
			width: min-content;
			margin-left: auto;
			margin-right: auto;
		}
		li.repo_clone > div {
			padding: 8px 8px 0 8px;
			font-weight: bold;
			white-space: nowrap;
		}
		li.repo_clone > code {
			display: inline-block;
			margin: 4px 8px 8px 8px;
			padding: 4px 8px;
			background-color: #f1f3f5;
			border: 1px solid #ced4da;
			border-radius: 4px;
			color: #212529;
			border-radius: 8px;
			font-family: monospace;
			font-size: 14px;
			cursor: pointer;
			user-select: all;
			white-space: nowrap;
			text-align: center;
		}
		#repo_clone_cmd:hover {
			background-color: #e9ecef;
		}
		#opcode-website {
			max-width: 600px; grid-area: 1 / 1 / span 1 / span 6;
		}
		#opcode-libs {
			max-width: 800px; grid-area: 1 / 7 / span 1 / span 6;
		}
		#dragons-labs {
			max-width: 900px; grid-area: 1 / 1 / span 1 / span 13;
		}
		#repo {
			max-width: none; grid-area: 1 / 1 / span 1 / span 13; justify-self: center;
		}
		@media all and (max-width: 1333px) {
			.menu > div > div {
				grid-template-columns: 100%;
			}
			#opcode-website {
				max-width: 100%; grid-area: 1 / 1 / span 1 / span 1;
			}
			#opcode-libs {
				max-width: 100%; grid-area: 2 / 1 / span 1 / span 1;
			}
			#dragons-labs {
				max-width: 100%; grid-area: 1 / 1 / span 1 / span 1;
			}
		}
	</style>
</head>
<body>
	<h1 style="font-size: 32px;">{{ title }}</h1>
"""

HTML_TEMPLATE_MAIN_INDEX = """
	{%- macro repo_li(name, url) %}
				<li>
					<div class="repo_name">{{ name }}</div>
					<br />
					<div class="repo_links">
						<a href="{{ url }}">GitHub</a>
						<a href="{{ bitbucket_org_url }}/{{ name }}">Bitbucket</a>
						<a href="{{ name }}">Local</a>
					</div>
				</li>
	{%- endmacro %}

	<h2>Git repository mirrors</h2>
	
	<div class="menu"> <div> <div>
	{%- if mode == 'dragons-labs' %}
		<div class="section" id="dragons-labs">
			<h3>Dragons-Labs</h3>
			<ul>
			{%- for name, url in repos -%}
				{{ repo_li(name, url) }}
			{%- endfor %}
			</ul>
		</div>
	{%- elif mode == 'opcode' %}
		<div class="section" id="opcode-website">
			<h3>OpCode Website</h3>
			<ul>
			{%- for name, url in website_repos -%}
				{{ repo_li(name, url) }}
			{%- endfor %}
			</ul>
		</div>
		<div class="section" id="opcode-libs">
			<h3>OpCode Libs</h3>
			<ul>
			{%- for name, url in libs_repos -%}
				{{ repo_li(name, url) }}
			{%- endfor %}
			</ul>
		</div>
	{%- endif %}
	</div> </div> </div>
"""

HTML_TEMPLATE_REPO_INDEX = """
	<h2>(from {{ repo_group_title }} project)</h2>
	
	<div class="menu"> <div> <div>
		<div class="section" id="repo">
			<h3>Git repository mirrors</h3>
			<ul>
				<li class="repo_clone">
					<div>Clone repo:</div>
					<br />
					<code onclick="selectText(this)">git clone {{ clone_base_url }}/{{ name }}</code>
				</li>
				<li><a href="{{ url }}">GitHub</a></li>
				<li><a href="{{ bitbucket_org_url }}/{{ name }}">Bitbucket</a></li>
				<li><a href="git.html">Browse repo here<br/><span style="font-size: x-small;">with JSWebGit (JavaScript client side Git web interface)</span></a></li>
			</ul>
		</div>
	</div> </div> </div>
"""

HTML_TEMPLATE_TAIL = """
</body>
</html>
"""
def main(args):
	if len(args) < 3:
		print(f"USE: {args[0]} dragons-labs|opcode output_dir", file=sys.stderr)
		sys.exit(1)
	
	mode = args[1]
	output_dir = args[2]
	
	if set(output_dir).intersection(set("""$'"`(){};|&\\""")):
		# NOTE: minimal protection against shell injection, but still
		#	   this script is not designed for be invoked with the privileges of a user other than the one who defines the argument values.
		print(f"output_dir argument ({output_dir}) contains not allowed characters", file=sys.stderr)
		sys.exit(1)
	
	if not os.path.isfile(f"{output_dir}/make-repos.sh"):
		os.system(f"mkdir -p '{output_dir}'; wget -O - https://opcode-eu-org-libs.github.io/JSWebGit/JSWebGit.tgz | tar -xzf - -C '{output_dir}'")
	
	if mode == "dragons-labs":
		context = {
			"title": "Sources for Dragons-Labs projects",
			"repo_group_title": "Dragons-Labs",
			"mode": mode,
			"clone_base_url": "https://src-dragons-labs.pages.dev",
			"bitbucket_org_url": "https://bitbucket.org/dragons-labs",
			"repos": get_repos_sorted("dragons-labs"),
		}
		all_repos = context["repos"]
	elif mode == "opcode":
		context = {
			"title": "Sources for OpCode.eu.org projects",
			"repo_group_title": "OpCode.eu.org",
			"mode": mode,
			"clone_base_url": "https://src.opcode.eu.org",
			"bitbucket_org_url": "https://bitbucket.org/OpCode-eu-org",
			"website_repos": get_repos_sorted("opcode-eu-org-website"),
			"libs_repos": get_repos_sorted("opcode-eu-org-libs"),
		}
		all_repos = context["website_repos"] + context["libs_repos"]
	else:
		print(f"Unknown mode: {mode}", file=sys.stderr)
		sys.exit(1)
	
	# create main index
	template = Template(HTML_TEMPLATE_HEAD + HTML_TEMPLATE_MAIN_INDEX + HTML_TEMPLATE_TAIL)
	html_content = template.render(context)
	
	output_path = Path(f"{output_dir}/index.html")
	output_path.write_text(html_content, encoding="utf-8")
	
	# create repo dirs and per repo index
	template = Template(HTML_TEMPLATE_HEAD + HTML_TEMPLATE_REPO_INDEX + HTML_TEMPLATE_TAIL)
	for name, url in all_repos:
		os.system(f"cd '{output_dir}'; echo '{name} {url}' | ./make-repos.sh useCurrent; mv '{name}/index.html' '{name}/git.html'")
		
		context["title"] = f"Sources for {name}"
		context["name"] = name
		context["url"] = url
		html_content = template.render(context)
		output_path = Path(f"{output_dir}/{name}/index.html")
		output_path.write_text(html_content, encoding="utf-8")

if __name__ == "__main__":
	main(sys.argv)
