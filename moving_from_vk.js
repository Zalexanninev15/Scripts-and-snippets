// Переезжаем с VK сообщества v1.0
// Инструкция:
// 0. Переходим сюда и бэкапим сообщество: https://new.vkmate.ru (https://vkmate.ru)
// 1. Идём сюда: https://vkhost.github.io
// 2. Читаем инструкцию, приложение выбираем VK Admin
// 3. Копируем токен (после авторизации и разрешения на использование приложения)
// 4. Ищем ID сообщества (можно в настройках сообщества найти номер - publicXXXXXXXXX, где XXXXXXXXX (может быть другая длина) - это ID сообщества)
// 5. F12 в браузере
// 6. В консоли Ctrl+V и жмём Enter.
// 7. Снизу будут логи, ожидайте.
// 8. Стена сообщества должна быть очищена (появится сообщение в браузере). 
// 9. Если стена ещё осталась - обновите страницу полностью (Ctrl+F5) и пролистайте стену до самого конца, чтобы прогрузились все посты и повторите пункт 6.

(async () => {
  const access_token = ''; // Вставьте сюда ваш токен
  const owner_id = -; // ID сообщества с минусом, например -123456

  // Функция для вызова VK API
  async function vkApi(method, params) {
    const url = new URL(`https://api.vk.com/method/${method}`);
    params.v = '5.131';
    params.access_token = access_token;
    Object.entries(params).forEach(([k,v]) => url.searchParams.append(k,v));
    const res = await fetch(url);
    const data = await res.json();
    if (data.error) throw new Error(JSON.stringify(data.error));
    return data.response;
  }

  // Получаем посты на стене сообщества (по 100 за раз)
  async function getPosts(offset = 0) {
    return await vkApi('wall.get', {
      owner_id,
      count: 100,
      offset
    });
  }

  // Удаляем пост по id
  async function deletePost(post_id) {
    return await vkApi('wall.delete', {
      owner_id,
      post_id
    });
  }

  try {
    let offset = 0;
    while (true) {
      const postsData = await getPosts(offset);
      const posts = postsData.items;
      if (posts.length === 0) {
        console.log('Все посты удалены.');
        break;
      }
      for (const post of posts) {
        console.log(`Удаляем пост id=${post.id}`);
        await deletePost(post.id);
        // Пауза, чтобы не перегружать API
        await new Promise(r => setTimeout(r, 300));
      }
      // После удаления 100 постов, проверяем следующую порцию
      offset += 100;
    }
    alert('Удаление всех постов завершено!');
  } catch (e) {
    console.error('Ошибка:', e);
    alert('Произошла ошибка: ' + e.message);
  }
})();
