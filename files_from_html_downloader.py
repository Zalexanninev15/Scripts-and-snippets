import os
import time
from pathlib import Path
from urllib.parse import urlparse

import requests
from bs4 import BeautifulSoup

# Папка, куда будут сохраняться все файлы
OUTPUT_DIR = "output"
# Заголовок User-Agent, чтобы выглядеть как обычный браузер
USER_AGENT = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/118.0.0.0 Safari/537.36"
# Задержка в секундах между скачиванием файлов, чтобы не получить бан
DOWNLOAD_DELAY = 1

def download_file(url, output_path, session):
    try:
        # Извлекается имя файла из URL
        filename = os.path.basename(urlparse(url).path)
        if not filename:
             # Если URL без имени файла (напр., "https://site.com/images/") — пропустить
            print(f"  [Пропуск] Не удалось определить имя файла для URL: {url}")
            return

        local_filepath = output_path / filename

        # Проверка, существует ли файл, чтобы не скачивать повторно
        if local_filepath.exists():
            print(f"  [Пропуск] Файл уже существует: {local_filepath}")
            return

        print(f"  [Скачивание] {url} -> {local_filepath}")

        # GET-запрос через сессию
        response = session.get(url, stream=True, timeout=20)
        response.raise_for_status()  # Вызовет исключение для статусов 4xx/5xx

        # Сохранение файла по частям
        with open(local_filepath, 'wb') as f:
            for chunk in response.iter_content(chunk_size=8192):
                if chunk:
                    f.write(chunk)

        # Задержка после успешного скачивания
        time.sleep(DOWNLOAD_DELAY)

    except requests.exceptions.RequestException as e:
        print(f"  [Ошибка] Не удалось скачать {url}: {e}")
    except Exception as e:
        print(f"  [Ошибка] Произошла непредвиденная ошибка при скачивании {url}: {e}")

def extract_and_download_from_html(html_file, output_path, session):
    print(f"\nОбработка файла: {html_file}")

    try:
        # Используется кодировка cp1251.
        # Если файлы в UTF-8, измените на encoding="utf-8"
        with open(html_file, 'r', encoding="cp1251", errors='ignore') as f:
            soup = BeautifulSoup(f, "html.parser")
    except Exception as e:
        print(f"[Ошибка] Не удалось открыть или распарсить {html_file}: {e}")
        return

    # Теги, которые могут содержать ссылки на ресурсы
    tags = soup.find_all(["img", "a", "link", "source", "script"])
    urls_to_download = set()

    for tag in tags:
        for attr in ["src", "href"]:
            url = tag.get(attr)
            
            if url and url.startswith(('http://', 'https://')):
                urls_to_download.add(url)

    if not urls_to_download:
        print("Абсолютных ссылок для скачивания не найдено.")
        return

    print(f"Найдено уникальных абсолютных ссылок: {len(urls_to_download)}")
    for url in sorted(list(urls_to_download)):
        download_file(url, output_path, session)

def main():
    print("--- Скрипт для скачивания ресурсов по абсолютным ссылкам из HTML-файлов ---")
    
    output_path = Path(OUTPUT_DIR)
    output_path.mkdir(exist_ok=True)

    root_dir = Path(".")
    html_files = list(root_dir.rglob("*.html")) + list(root_dir.rglob("*.htm"))

    if not html_files:
        print("В текущей директории и её подпапках не найдено HTML-файлов.")
        return

    print(f"\nНайдено HTML-файлов: {len(html_files)}")
    
    with requests.Session() as session:
        session.headers.update({"User-Agent": USER_AGENT})

        for html_file in html_files:
            extract_and_download_from_html(html_file, output_path, session)

    print("\n--- Работа завершена ---")

if __name__ == "__main__":
    main()
