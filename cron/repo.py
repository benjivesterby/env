#!/usr/bin/python3

import requests
import subprocess
import os
import json
import logging

logging.basicConfig(level=logging.DEBUG)

# Pull the GitHub Personal Access Token from an environment variable
TOKEN = os.getenv('GITHUB_PAT')
if not TOKEN:
    raise EnvironmentError("The GITHUB_PAT environment variable is not set.")

# Pull the base directory path from an environment variable, with a fallback default
BASE_DIR = os.getenv('GITHUB_REPO_BASE_DIR', '/home/benji/src')

# Ensure users.json and orgs.json paths are correctly set based on BASE_DIR or another logic
USERS_FILE = os.path.join(BASE_DIR, 'users.json')
ORGS_FILE = os.path.join(BASE_DIR, 'orgs.json')

# Load users and orgs from their respective JSON files
with open(USERS_FILE, 'r') as f:
    users = json.load(f)

with open(ORGS_FILE, 'r') as f:
    orgs = json.load(f)

headers = {"Authorization": f"Bearer {TOKEN}"}

# GraphQL query template for fetching repositories, including forks
query_template = """
query($login: String!, $afterCursor: String, $isFork: Boolean!) {
  user(login: $login) {
    repositories(first: 100, after: $afterCursor, isFork: $isFork) {
      pageInfo {
        hasNextPage
        endCursor
      }
      edges {
        node {
          name
          sshUrl
          owner {
            login
          }
        }
      }
    }
  }
  organization(login: $login) {
    repositories(first: 100, after: $afterCursor, isFork: $isFork) {
      pageInfo {
        hasNextPage
        endCursor
      }
      edges {
        node {
          name
          sshUrl
          owner {
            login
          }
        }
      }
    }
  }
}
"""
def run_query(query, variables):
    try:
        request = requests.post('https://api.github.com/graphql', json={'query': query, 'variables': variables}, headers=headers)
        request.raise_for_status()
        return request.json()
    except requests.exceptions.RequestException as e:
        logging.error(f"Request failed: {e}")
        raise

def convert_ssh_to_https(ssh_url):
    # Convert SSH URL to HTTPS URL
    if ssh_url.startswith("git@github.com:"):
        https_url = ssh_url.replace("git@github.com:", "https://github.com/")
        https_url = https_url.replace(".git", "")
        return https_url
    return ssh_url

def fetch_repositories_for_login(login, is_fork):
    all_repositories = []
    has_next_page = True
    after_cursor = None

    while has_next_page:
        variables = {"login": login, "afterCursor": after_cursor, "isFork": is_fork}
        result = run_query(query_template, variables)
        user_repos = result['data'].get('user')
        org_repos = result['data'].get('organization')

        repos_data = user_repos if user_repos else org_repos
        if repos_data:
            repositories = repos_data['repositories']['edges']
            page_info = repos_data['repositories']['pageInfo']
            all_repositories.extend(repositories)

            has_next_page = page_info['hasNextPage']
            after_cursor = page_info['endCursor']
        else:
            break

    return all_repositories

def process_repository(repo, is_fork):
    name = repo['node']['name']
    ssh_url = repo['node']['sshUrl']
    #https_url = convert_ssh_to_https(ssh_url)
    owner = repo['node']['owner']['login']
    repo_path = os.path.join(BASE_DIR, owner, "forks" if is_fork else "", name)

    if not os.path.exists(repo_path):
        os.makedirs(repo_path)
        print(f"Cloning {name} into {repo_path}...")
        clone_cmd = ["git", "clone", ssh_url, repo_path]
        subprocess.run(clone_cmd)
    else:
        print(f"Repository {name} already exists. Checking and updating remote URL if necessary...")
        os.chdir(repo_path)
        subprocess.run(["git", "remote", "set-url", "origin", ssh_url])
        subprocess.run(["git", "pull"])

def main():
    logins = users + orgs
    for login in logins:
        # First, process non-forked repositories
        repositories = fetch_repositories_for_login(login, is_fork=False)
        for repo in repositories:
            process_repository(repo, is_fork=False)
        
        # Then, process forked repositories
        forks = fetch_repositories_for_login(login, is_fork=True)
        for fork in forks:
            process_repository(fork, is_fork=True)

if __name__ == "__main__":
    main()


