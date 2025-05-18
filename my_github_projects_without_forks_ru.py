import requests
import json
import re
from groq import Groq

# https://console.groq.com/keys
# Глобальная переменная для контроля использования Groq API
use_groq_api = False

def get_github_repos(username):
    url = f"https://api.github.com/users/{username}/repos?per_page=100"
    response = requests.get(url)

    if response.status_code == 200:
        # Сортируем репозитории по количеству звезд (от большего к меньшему)
        repos = sorted(response.json(), key=lambda repo: repo.get(
            'stargazers_count', 0), reverse=True)
        return repos
    else:
        print(f"Ошибка при получении репозиториев: {response.status_code}")
        return []

# Функция для сокращения описания с помощью Groq API
def shorten_description(api_key, description, max_length=150):
    if not description:
        return ""

    if len(description) <= max_length:
        return description

    # Если произошла ошибка при первом запросе к Groq API,
    # отключаем использование API для всех последующих запросов
    global use_groq_api

    if not use_groq_api:
        return description[:max_length-3] + "..." if len(description) > max_length else description

    try:
        client = Groq(api_key=api_key)
        prompt = f"""Сократи следующее описание GitHub репозитория до 150 символов или меньше, 
                    сохраняя ключевую информацию и суть проекта:
                    
                    {description}
                    
                    Твой ответ должен содержать ТОЛЬКО сокращенный текст без дополнительных комментариев."""

        chat_completion = client.chat.completions.create(
            messages=[
                {
                    "role": "user",
                    "content": prompt,
                }
            ],
            model="mixtral-8x7b-32768",  # Используем модель, которая точно доступна в Groq
        )

        shortened = chat_completion.choices[0].message.content.strip()
        return shortened
    except Exception as e:
        print(f"Ошибка при использовании Groq API: {e}")
        print("Переключение на механическое сокращение текста...")
        use_groq_api = False  # Отключаем использование API для последующих запросов
        return description[:max_length-3] + "..." if len(description) > max_length else description


def main():
    # Константы
    GITHUB_USERNAME = "Zalexanninev15"

    # Глобальная переменная для контроля использования Groq API
    global use_groq_api
    use_groq_api = False  # По умолчанию не используем API

    # Запрашиваем API-ключ Groq у пользователя
    groq_api_key = input(
        "Введите ваш API-ключ Groq (нажмите Enter, чтобы пропустить использование Groq): ")
    if groq_api_key.strip():
        use_groq_api = True  # Включаем использование API, если ключ предоставлен

    # Получаем все репозитории пользователя
    print(f"Получение репозиториев для пользователя {GITHUB_USERNAME}...")
    repos = get_github_repos(GITHUB_USERNAME)

    projects = []

    # Обрабатываем каждый репозиторий
    for repo in repos:
        # Пропускаем форки, если они не представляют отдельный интерес
        if repo["fork"]:
            continue

        title = repo["name"]
        description = repo["description"] or ""
        url = repo["html_url"]
        stars = repo["stargazers_count"]
        forks = repo["forks_count"]

        # Пропускаем проекты без описания
        if not description:
            continue

        # Сокращаем описание
        if use_groq_api and groq_api_key and description:
            shortened_description = shorten_description(
                groq_api_key, description)
        else:
            # Простое механическое сокращение, если нет API ключа или API отключен
            if len(description) > 150:
                shortened_description = description[:147] + "..."
            else:
                shortened_description = description

        # Добавляем проект в список с информацией о звездах и форках
        projects.append({
            "title": title,
            "description": shortened_description,
            "stats": {
                "stars": stars,
                "forks": forks
            },
            "url": url
        })

    # Добавляем специальный проект xdpl в конец, теперь с информацией о статистике
    projects.append({
        "title": "xdpl",
        "description": "GUI для патчера xdelta. Улучшенный форк xdPatcher.",
        "stats": {
            "stars": 2,
            "forks": 0
        },
        "url": "https://github.com/Zalexanninev15/xdpl"
    })

    # Сохраняем результат в JSON-файл
    with open("github_projects.json", "w", encoding="utf-8") as f:
        json.dump(projects, f, ensure_ascii=False, indent=2)

    print(
        f"Готово! Сохранено {len(projects)} проектов в файл github_projects.json")
    print(f"Всего обработано репозиториев: {len(repos)}")


if __name__ == "__main__":
    main()