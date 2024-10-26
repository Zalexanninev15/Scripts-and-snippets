import os
from dotenv import load_dotenv
import base64
from github import Github
from github import GithubException
from tqdm import tqdm

load_dotenv()

REPOS_DIR = "Repos"

def ensure_repos_dir():
    if not os.path.exists(REPOS_DIR):
        os.makedirs(REPOS_DIR)


def download_readmes(g):
    ensure_repos_dir()
    user = g.get_user()
    repos = list(user.get_repos())

    with tqdm(total=len(repos), desc="Скачивание README файлов") as pbar:
        for repo in repos:
            if not repo.fork:
                try:
                    content = repo.get_contents("README.md")
                    readme_content = base64.b64decode(content.content).decode('utf-8')

                    file_path = os.path.join(REPOS_DIR, f"{repo.name}.md")
                    with open(file_path, "w", encoding="utf-8") as file:
                        file.write(readme_content)

                    pbar.set_postfix_str(f"Скачан README из {repo.name}")
                except GithubException:
                    pbar.set_postfix_str(f"README не найден в {repo.name}")
            pbar.update(1)


def upload_readmes(g):
    ensure_repos_dir()
    user = g.get_user()
    repos = list(user.get_repos())

    with tqdm(total=len(repos), desc="Загрузка README файлов") as pbar:
        for repo in repos:
            if not repo.fork:
                file_path = os.path.join(REPOS_DIR, f"{repo.name}.md")
                if os.path.exists(file_path):
                    with open(file_path, "r", encoding="utf-8") as file:
                        content = file.read()

                    try:
                        readme = repo.get_contents("README.md")
                        repo.update_file(
                            "README.md",
                            "Update README.md",
                            content,
                            readme.sha
                        )
                        pbar.set_postfix_str(f"Обновлен README в {repo.name}")
                    except GithubException:
                        repo.create_file("README.md", "Create README.md", content)
                        pbar.set_postfix_str(f"Создан README в {repo.name}")
            pbar.update(1)


def main():
    token = os.getenv("GITHUB_FULL_ACCESS_CLASSIC_TOKEN")
    g = Github(token)
    print("GitHub READMES UPDATER")
    while True:
        print("\n1. Скачать README файлы")
        print("2. Загрузить изменения README файлов")
        print("3. Выход")

        choice = input("Выберите действие (1/2/3): ")

        if choice == "1":
            download_readmes(g)
        elif choice == "2":
            upload_readmes(g)
        elif choice == "3":
            break
        else:
            print("Неверный выбор. Попробуйте еще раз.")


if __name__ == "__main__":
    main()