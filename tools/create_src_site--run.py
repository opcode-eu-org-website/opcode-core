#!/usr/bin/python3

# SPDX-FileCopyrightText: Robert Ryszard Paciorek <rrp@opcode.eu.org>
# SPDX-License-Identifier: MIT

# Created with Gemini AI, 2026


# ZALEŻNOŚCI: `sudo apt install -y python3-cryptography python3-requests python3-jwt`


# ODPOWIEDNIK:
#
# curl -L \
# 	-X POST \
# 	-H "Accept: application/vnd.github+json" \
# 	-H "Authorization: Bearer <YOUR-TOKEN>" \
# 	-H "X-GitHub-Api-Version: 2026-03-10" \
# 	https://api.github.com/repos/opcode-eu-org-website/OpCode-core/actions/workflows/deploy-src_sites.yml/dispatches \
# 	-d '{"ref":"master","inputs":{"deploy_mode":"'$1'"}}'
#
# ale bez problemu wygasania tokenu ... za to z utworzeniem "GitHub App" (z odpowiednimi uprawnieniami) i instalacji jej (na odpowiednim repo)


import sys, os, json, time
import jwt
import requests

mode, = sys.argv[1:2] or [None]
modes = ["dragons-labs", "opcode"]

if mode not in modes:
	print(f"USE: {sys.argv[0]} {'|'.join(modes)}", file=sys.stderr)
	sys.exit(1)

# --- KONFIGURACJA ---
APP_INFO_PATH = '../private/actiontrigger.json'
REPO_OWNER = "opcode-eu-org-website"
REPO_NAME = "OpCode-core"
WORKFLOW_FILE = "deploy-src_sites.yml"
WORKFLOW_BRANCH_REF = "master"
WORKFLOW_INPUTS = {
	"deploy_mode": mode
}

def load_app_info(filepath: str):
	"""Wczytuje APP_ID i INSTALLATION_ID z pliku JSON."""
	
	filepath = os.path.expanduser(filepath)
	if not os.path.isabs(filepath):
		script_dir = os.path.dirname(os.path.abspath(__file__))
		filepath = os.path.join(script_dir, filepath)
	
	with open(filepath, 'r') as file:
		data = json.load(file)
		
	private_key_path = os.path.expanduser(data['PRIVATE_KEY_PATH'])
	if not os.path.isabs(private_key_path):
		private_key_path = os.path.join(os.path.dirname(filepath), private_key_path)
	
	return str(data['APP_ID']), str(data['INSTALLATION_ID']), private_key_path

def generate_jwt(app_id: str, private_key_path: str) -> str:
	"""Generuje JSON Web Token (JWT) do autoryzacji jako GitHub App."""
	with open(private_key_path, 'r') as key_file:
		private_key = key_file.read()

	payload = {
		# Czas utworzenia tokenu (z marginesem -60s na wypadek asynchronizacji zegarów)
		'iat': int(time.time()) - 60,
		# Czas wygaśnięcia tokenu (maksymalnie 5 minut)
		'exp': int(time.time()) + (5 * 60),
		'iss': app_id
	}
	
	return jwt.encode(payload, private_key, algorithm='RS256')

def get_installation_token(jwt_token: str, installation_id: str) -> str:
	"""Pobiera Installation Access Token z użyciem wygenerowanego JWT."""
	url = f"https://api.github.com/app/installations/{installation_id}/access_tokens"
	headers = {
		'Authorization': f'Bearer {jwt_token}',
		'Accept': 'application/vnd.github.v3+json'
	}
	
	response = requests.post(url, headers=headers)
	response.raise_for_status()
	return response.json()['token']

def trigger_workflow(access_token: str, owner: str, repo: str, workflow_id: str, ref: str, inputs = {}):
	"""Uruchamia GitHub Action poprzez endpoint workflow_dispatch."""
	url = f"https://api.github.com/repos/{owner}/{repo}/actions/workflows/{workflow_id}/dispatches"
	headers = {
		'Authorization': f'token {access_token}',
		'Accept': 'application/vnd.github.v3+json'
	}
	
	payload = {
		'ref': ref,
		'inputs': inputs
	}
	
	response = requests.post(url, headers=headers, json=payload)
	response.raise_for_status()
	print(f"Workflow '{workflow_id}' triggered successfully on branch '{ref}'.")

if __name__ == "__main__":
	try:
		app_id, installation_id, private_key_path = load_app_info(APP_INFO_PATH)
		
		app_jwt = generate_jwt(app_id, private_key_path)
		install_token = get_installation_token(app_jwt, installation_id)
		trigger_workflow(install_token, REPO_OWNER, REPO_NAME, WORKFLOW_FILE, WORKFLOW_BRANCH_REF, WORKFLOW_INPUTS)
		
	except requests.exceptions.HTTPError as err:
		print(f"Błąd API GitHuba: {err.response.status_code} - {err.response.text}")
	except Exception as e:
		print(f"Wystąpił błąd: {e}")
