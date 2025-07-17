// Разблокируем ачивки в Sharkey (Misskey)

// Шаг 0
// Идём сюда: https://shitpost.poridge.club/api-console (или на другом инстанте в консольку)
// В endpoint вставляем: i/claim-achievement
// Нажимаем F12
 
// Шаг 1 (если только Шаг 2 не заработал с первой попытки)
// Выполняем код и выбираем текстовое поле под "Params (JSON or JSON5)"
(function() {
    function generateSelector(el) {
        if (!el) return;
        console.log("--- Найден элемент! ---");
        console.log("HTML-код элемента:", el.outerHTML);
        
        if (el.id) {
            console.log(`✅ Идеальный селектор (по ID): '#${el.id}'`);
        }
        if (el.className) {
            const classSelector = `textarea.${el.className.trim().replace(/\s+/g, '.')}`;
            console.log(`👍 Хороший селектор (по классу): '${classSelector}'`);
        }
        if (el.name) {
            console.log(`- Селектор (по имени): 'textarea[name="${el.name}"]'`);
        }
        if (el.placeholder) {
            console.log(`- Селектор (по placeholder): 'textarea[placeholder="${el.placeholder}"]'`);
        }
        console.log("--- Скопируйте один из селекторов выше (предпочтительно с ✅ или 👍) и вставьте в основной скрипт. ---");
    }
 
    const clickHandler = (e) => {
        e.preventDefault();
        e.stopPropagation();
        document.removeEventListener('click', clickHandler, true);
        generateSelector(e.target);
    };
 
    console.log("Готов к работе. Теперь кликните ТОЧНО на нужном текстовом поле на странице.");
    document.addEventListener('click', clickHandler, { capture: true });
})();
 
// Шаг 2
// Вставьте значение селектора, которое вы получили на Шаге 1.
const textareaSelector = 'textarea.MkTextarea-textarea-j1il._monospace';

const sleep = (ms) => new Promise(resolve => setTimeout(resolve, ms));

// Список ачивок взят отсюда: https://activitypub.software/TransFem-org/Sharkey/-/blob/develop/packages/frontend/src/utility/achievements.ts
const data = [
  { "name": "notes1" },
  { "name": "notes10" },
  { "name": "notes100" },
  { "name": "notes500" },
  { "name": "notes1000" },
  { "name": "notes5000" },
  { "name": "notes10000" },
  { "name": "notes20000" },
  { "name": "notes30000" },
  { "name": "notes40000" },
  { "name": "notes50000" },
  { "name": "notes60000" },
  { "name": "notes70000" },
  { "name": "notes80000" },
  { "name": "notes90000" },
  { "name": "notes100000" },
  { "name": "login3" },
  { "name": "login7" },
  { "name": "login15" },
  { "name": "login30" },
  { "name": "login60" },
  { "name": "login100" },
  { "name": "login200" },
  { "name": "login300" },
  { "name": "login400" },
  { "name": "login500" },
  { "name": "login600" },
  { "name": "login700" },
  { "name": "login800" },
  { "name": "login900" },
  { "name": "login1000" },
  { "name": "passedSinceAccountCreated1" },
  { "name": "passedSinceAccountCreated2" },
  { "name": "passedSinceAccountCreated3" },
  { "name": "loggedInOnBirthday" },
  { "name": "loggedInOnNewYearsDay" },
  { "name": "noteClipped1" },
  { "name": "noteFavorited1" },
  { "name": "myNoteFavorited1" },
  { "name": "profileFilled" },
  { "name": "markedAsCat" },
  { "name": "following1" },
  { "name": "following10" },
  { "name": "following50" },
  { "name": "following100" },
  { "name": "following300" },
  { "name": "followers1" },
  { "name": "followers10" },
  { "name": "followers50" },
  { "name": "followers100" },
  { "name": "followers300" },
  { "name": "followers500" },
  { "name": "followers1000" },
  { "name": "collectAchievements30" },
  { "name": "viewAchievements3min" },
  { "name": "iLoveMisskey" },
  { "name": "foundTreasure" },
  { "name": "client30min" },
  { "name": "client60min" },
  { "name": "noteDeletedWithin1min" },
  { "name": "postedAtLateNight" },
  { "name": "postedAt0min0sec" },
  { "name": "selfQuote" },
  { "name": "htl20npm" },
  { "name": "viewInstanceChart" },
  { "name": "outputHelloWorldOnScratchpad" },
  { "name": "open3windows" },
  { "name": "driveFolderCircularReference" },
  { "name": "reactWithoutRead" },
  { "name": "clickedClickHere" },
  { "name": "justPlainLucky" },
  { "name": "setNameToSyuilo" },
  { "name": "cookieClicked" },
  { "name": "brainDiver" },
  { "name": "smashTestNotificationButton" },
  { "name": "tutorialCompleted" },
  { "name": "bubbleGameExplodingHead" },
  { "name": "bubbleGameDoubleExplodingHead" }
];
 
async function processItems(textarea) {
    console.log("Элемент найден! Начинаю обработку...");
    function findSendButton() {
        const buttons = document.querySelectorAll('button');
        for (const button of buttons) {
            if (button.textContent.trim().toLowerCase() === 'send') return button;
        }
        return null;
    }
    for (let i = 0; i < data.length; i++) {
        const item = data[i];
        const sendButton = findSendButton();
        if (!sendButton) {
            console.error("ОШИБКА: Кнопка 'Send' не найдена. Скрипт остановлен.");
            return;
        }
        console.log(`[${i + 1}/${data.length}] Обработка: ${item.name}`);
        const jsonString = JSON.stringify(item, null, 2);
        textarea.value = jsonString;
        textarea.dispatchEvent(new Event('input', { bubbles: true }));
        console.log("Данные вставлены, нажимаю 'Send'...");
        sendButton.click();
        await sleep(1000);
    }
    console.log("ГОТОВО! Все элементы из списка обработаны.");
}
 
function waitForElement(selector, callback) {
    if (!selector || selector === '...ВСТАВЬТЕ ВАШ СЕЛЕКТОР СЮДА...') {
        console.error("ОШИБКА: Вы не вставили селектор в основной скрипт. Пожалуйста, выполните Шаг 1 и Шаг 2.");
        return;
    }
    const interval = setInterval(() => {
        const element = document.querySelector(selector);
        if (element) {
            clearInterval(interval);
            callback(element);
        }
    }, 200);
    setTimeout(() => {
        if (document.querySelector(selector) == null) {
           clearInterval(interval);
           console.error(`ОШИБКА: Элемент все равно не был найден за 10 секунд по вашему селектору: "${selector}"`);
           console.error("Возможно, элемент находится внутри <iframe>. Щелкните на нем правой кнопкой мыши. Если есть пункт 'View frame source' или 'Перезагрузить фрейм', сообщите мне об этом.");
        }
    }, 10000);
}
 
// Запуск
console.log(`Идет поиск элемента по вашему селектору: "${textareaSelector}"...`);
waitForElement(textareaSelector, processItems);
