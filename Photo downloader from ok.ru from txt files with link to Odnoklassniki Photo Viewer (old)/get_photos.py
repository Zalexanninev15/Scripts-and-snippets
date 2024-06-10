import os
import random
import shutil
import string
from os import system
from random import randrange
import time
import requests
import uuid
from bs4 import BeautifulSoup as BSHTML
import urllib

photo_num = 0

def FileNameGenerator():
    letters_and_digits = string.ascii_letters + string.digits
    rand_string = ''.join(random.sample(letters_and_digits, 8))
    return rand_string

def OnePhotoDownloader(url, to, extension):
    headers = {"User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/70.0.3538.77 Safari/537.36"}
    pageF = requests.get(url=url, headers=headers).text
    soup = BSHTML(pageF, features="lxml")
    images = soup.findAll('img')
    for img in images:
        if len(img['src']) <= 72 and not '-' in img['src'] and not 'about:blank' in img['src']:
            photoFile = requests.get(f"https:{img['src']}", headers=headers)
            filename = f"{to}\{FileNameGenerator()}.{extension}"
            open(filename, "wb").write(photoFile.content)

thisDir = "D:\MyProfile\Downloads\OK"
files = os.listdir()
if os.path.exists(f'{thisDir}\Photos') == True:
        shutil.rmtree(f'{thisDir}\Photos')
os.mkdir(f'{thisDir}\Photos')
phtoAlb = ""
for file1 in files:
    with open(file1, 'r') as file:
            for line in file:
                l = line.strip()
                if '/' in l:
                    link = f"https://ok.ru{l}"
                    OnePhotoDownloader(link, phtoAlb, 'jpg')
                    photo_num += 1
                    print(f"{photo_num}")
                    time.sleep(4)
                elif l.startswith('!'):
                    dpg = randrange(70)
                    print(f'{l}={dpg}')
                    phtoAlb = f'{thisDir}\Photos\{dpg}'
                    os.mkdir(phtoAlb)
                    photo_num = 0