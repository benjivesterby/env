#!/usr/bin/python3

import os
import subprocess
import argparse
import re

def is_git_repo(path):
    """Check if the directory is a Git repository."""
    return os.path.isdir(os.path.join(path, '.git'))

def should_exclude(directory, exclude_patterns):
    """Check if the directory should be excluded based on the patterns."""
    return any(excl in directory for excl in exclude_patterns)

def check_git_status(directory, exclude_patterns):
    uncommitted_repos = []
    for root, dirs, files in os.walk(directory, topdown=True):
        # Modify dirs in-place to skip excluded directories based on pattern matching
        dirs[:] = [d for d in dirs if not should_exclude(os.path.join(root, d), exclude_patterns)]
        if is_git_repo(root):
            try:
                # Change into the directory that contains the .git folder
                os.chdir(root)
                # Check the git status
                result = subprocess.run(['git', 'status', '--porcelain'], stdout=subprocess.PIPE, stderr=subprocess.PIPE)
                # If there is any output, there are uncommitted changes
                if result.stdout:
                    uncommitted_repos.append(os.path.abspath(root))
            except Exception as e:
                print(f"Error processing {root}: {e}")
            finally:
                # Reset directory to avoid interference with os.walk
                os.chdir(directory)
    
    return uncommitted_repos

def write_uncommitted_repos_to_file(uncommitted_repos, output_file):
    with open(output_file, 'w') as file:
        for repo in uncommitted_repos:
            file.write(repo + '\n')

def main():
    parser = argparse.ArgumentParser(description='Recursively check directories for uncommitted Git changes, excluding specified patterns.')
    parser.add_argument('directory', type=str, help='Root directory to begin checking for Git repositories.')
    parser.add_argument('output_file', type=str, help='File to write the paths with uncommitted changes.')
    parser.add_argument('--exclude', type=str, help='Comma-separated list of substrings to exclude directories that contain any of them.')

    args = parser.parse_args()

    exclude_patterns = args.exclude.split(',') if args.exclude else []

    uncommitted_repos = check_git_status(args.directory, exclude_patterns)
    write_uncommitted_repos_to_file(uncommitted_repos, args.output_file)

if __name__ == '__main__':
    main()

