import requests
import json
import os
import time
import sys

def fetch_all_archived_urls(domain):
    print(f"Retrieving archived URLs for domain {domain}...")
    
    cdx_url = f"https://web.archive.org/cdx/search/cdx?url={domain}/*&output=json&fl=timestamp,original&collapse=urlkey"
    response = requests.get(cdx_url)
    
    if response.status_code != 200:
        print(f"Error requesting CDX API: {response.status_code}")
        return []
    
    try:
        data = response.json()
        if not data or len(data) <= 1:  # Check for empty response or header only
            print("No archived URLs found")
            return []
        
        # Skip the first row (headers)
        entries = data[1:]
        
        # Collect unique URLs
        unique_urls = set()
        wayback_urls = []
        
        for timestamp, original_url in entries:
            unique_urls.add(original_url)
            wayback_url = f"https://web.archive.org/web/{timestamp}/{original_url}"
            wayback_urls.append(wayback_url)
        
        print(f"Found {len(entries)} archive snapshots")
        print(f"Found {len(unique_urls)} unique original URLs")
        print(f"Generated {len(wayback_urls)} Wayback Machine URLs")
        
        return wayback_urls
    
    except Exception as e:
        print(f"Error processing CDX data: {e}")
        return []

def save_urls_to_file(urls, filename):
    with open(filename, 'w') as f:
        for url in urls:
            f.write(f"{url}\n")
    print(f"URLs saved to file {filename}")

if __name__ == "__main__":
    print("QUWA v1.0 (Get Urls from WebArchive) by Zalexanninev15") 
    if len(sys.argv) < 2:
        print("Usage: python ./QUWA.py domain.com")
        sys.exit(1)
        
    domain = sys.argv[1]
    output_file = f"{domain}.txt"
    
    urls = fetch_all_archived_urls(domain)
    if urls:
        save_urls_to_file(urls, output_file)
        print(f"Done!\nPreview: cat {output_file}")