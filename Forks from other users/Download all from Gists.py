import os
import sys
import json
import hashlib
import requests
import logging

from subprocess import call, CalledProcessError
from concurrent.futures import ThreadPoolExecutor as PoolExecutor

# Set up basic logging
logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(levelname)s - %(message)s')

def download_all_from_user(user: str):
    next_page = True
    page = 1
    
    while next_page:
        url = f"https://api.github.com/users/{user}/gists?page={page}"
        response = requests.get(url)

        try:
            gists = response.json()
            if not gists:
                next_page = False
                continue
        except json.JSONDecodeError:
            logging.error("Invalid JSON response")
            break

        page += 1
        download_all(gists)

def download_all(gists: list):
    with PoolExecutor(max_workers=10) as executor:
        for _ in executor.map(download, gists):
            pass

def download(gist):
    if "id" not in gist or "updated_at" not in gist or "git_pull_url" not in gist:
        logging.error("Missing required gist information")
        return

    target = gist["id"] + hashlib.md5(gist["updated_at"].encode('utf-8')).hexdigest()

    try:
        call(["git", "clone", gist["git_pull_url"], target])
    except CalledProcessError as e:
        logging.error(f"Failed to clone gist: {e}")
        return

    description_file = os.path.join(target, "description.txt")
    
    try:
        with open(description_file, "w") as f:
            f.write(f"{gist.get('description', 'No description')}\n")
    except IOError as e:
        logging.error(f"Failed to write description file: {e}")

# Main execution
if __name__ == "__main__":
    if len(sys.argv) > 1:
        user = sys.argv[1]
        download_all_from_user(user)
    else:
        logging.error("No user specified")