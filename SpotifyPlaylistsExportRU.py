import spotipy
from spotipy.oauth2 import SpotifyOAuth
import csv
import os
import time

def setup_spotify_client():
    """Настройка клиента Spotify с авторизацией без открытия браузера"""
    scope = "user-library-read playlist-read-private playlist-read-collaborative"
    
    # Необходимо указать свои данные из Spotify Developer Dashboard
    client_id = ""
    client_secret = ""
    # Можно взять с freemyip.com
    redirect_uri = ""
    # Пример ссылки для redirect_uri и Spotify Developer Dashboard: https://example72662.freemyip.com:8888/callback
    
    auth_manager = SpotifyOAuth(
        client_id=client_id,
        client_secret=client_secret,
        redirect_uri=redirect_uri,
        scope=scope,
        open_browser=False)
    
    # Получаем URL для авторизации
    auth_url = auth_manager.get_authorize_url()
    print(f"Пожалуйста, перейдите по следующему URL в вашем браузере: {auth_url}")
    
    # Запрашиваем URL, на который был сделан редирект после авторизации
    response = input("Вставьте полный URL, на который вас перенаправило после авторизации (стианица будет пустой или не загрузится): ")
    
    # Получаем токен из ответа
    code = auth_manager.parse_response_code(response)
    token_info = auth_manager.get_access_token(code)
    
    sp = spotipy.Spotify(auth=token_info['access_token'])
    return sp

def get_user_playlists(sp):
    """Получение всех плейлистов пользователя"""
    results = sp.current_user_playlists()
    playlists = results['items']
    
    # Получение всех плейлистов (обработка пагинации)
    while results['next']:
        results = sp.next(results)
        playlists.extend(results['items'])
    
    return playlists

def get_tracks_from_playlist(sp, playlist_id):
    """Извлечение всех треков из плейлиста"""
    results = sp.playlist_tracks(playlist_id)
    tracks = results['items']
    
    # Получение всех треков (обработка пагинации)
    while results['next']:
        results = sp.next(results)
        tracks.extend(results['items'])
    
    return tracks

def save_tracks_to_csv(tracks, playlist_name):
    """Сохранение треков в CSV файл используя стандартный модуль csv"""
    # Создание директории для экспорта, если её нет
    if not os.path.exists("spotify_exports"):
        os.makedirs("spotify_exports")
    
    # Определение полей для заголовка CSV
    headers = ['Название', 'Исполнитель', 'Альбом', 'Дата добавления', 
               'Длительность (мс)', 'Популярность', 'ID', 'URI', 'Ссылка']
    
    # Подготовка безопасного имени файла
    safe_name = ''.join(c if c.isalnum() or c in [' ', '_', '-'] else '_' for c in playlist_name)
    file_path = f"spotify_exports/{safe_name}.csv"
    
    # Запись данных в CSV
    with open(file_path, 'w', newline='', encoding='utf-8-sig') as csvfile:
        writer = csv.DictWriter(csvfile, fieldnames=headers)
        writer.writeheader()
        
        for item in tracks:
            track = item['track']
            if track:  # Проверка, что трек существует
                track_info = {
                    'Название': track['name'],
                    'Исполнитель': ', '.join([artist['name'] for artist in track['artists']]),
                    'Альбом': track['album']['name'],
                    'Дата добавления': item['added_at'],
                    'Длительность (мс)': track['duration_ms'],
                    'Популярность': track['popularity'],
                    'ID': track['id'],
                    'URI': track['uri'],
                    'Ссылка': track['external_urls']['spotify'] if 'external_urls' in track and 'spotify' in track['external_urls'] else ''
                }
                writer.writerow(track_info)
    
    return file_path

def export_saved_tracks(sp):
    """Экспорт избранных треков"""
    print("Экспорт избранных треков...")
    results = sp.current_user_saved_tracks()
    saved_tracks = results['items']
    
    # Получение всех сохраненных треков (обработка пагинации)
    while results['next']:
        results = sp.next(results)
        saved_tracks.extend(results['items'])
    
    file_path = save_tracks_to_csv(saved_tracks, "Избранное")
    print(f"Экспортировано {len(saved_tracks)} избранных треков в {file_path}")

def is_user_owned_playlist(sp, playlist):
    """Проверка, является ли плейлист созданным пользователем"""
    user_id = sp.current_user()['id']
    return playlist['owner']['id'] == user_id

def main():
    print("Начинаем экспорт треков Spotify...")
    
    # Инициализация клиента Spotify
    sp = setup_spotify_client()
    
    # Экспорт избранных треков
    export_saved_tracks(sp)
    
    # Экспорт плейлистов
    playlists = get_user_playlists(sp)
    print(f"Найдено {len(playlists)} плейлистов")
    
    # Файл для ссылок на публичные плейлисты
    with open("spotify_exports/playlist_links.txt", "w", encoding="utf-8") as links_file:
        for playlist in playlists:
            playlist_name = playlist['name']
            playlist_id = playlist['id']
            
            # Добавляем небольшую задержку, чтобы избежать превышения лимита API
            time.sleep(0.2)
            
            # Проверка, является ли плейлист созданным пользователем или приватным
            if is_user_owned_playlist(sp, playlist) or not playlist['public']:
                print(f"Экспорт плейлиста: {playlist_name}")
                tracks = get_tracks_from_playlist(sp, playlist_id)
                file_path = save_tracks_to_csv(tracks, playlist_name)
                print(f"  Экспортировано {len(tracks)} треков в {file_path}")
            else:
                # Для публичных плейлистов просто сохраняем ссылку
                print(f"Сохранение ссылки на публичный плейлист: {playlist_name}")
                links_file.write(f"{playlist_name}: {playlist['external_urls']['spotify']}\n")
    
    print("Экспорт завершен!")

if __name__ == "__main__":
    main()