<?php
#путь к файлу с будущими логами
$log_path = './logs/' . date("ymd") . '.txt';
#берем из переменной окружения ip-адрес посетителя...
$user_ip = getenv(REMOTE_ADDR );
#... и его тип браузера
$user_brouser = getenv(HTTP_USER_AGENT);
#узнаем сегодняшнее число и время
$curent_time = date("ymd H:i:s");
#Компонуем все данные в одну строку (для удобства)
$log_string = "$user_ip $user_brouser $curent_time\r\n";
#открываем файл для добавления в него (все добавляется в конец старого файла)
$file = fopen($log_path,"a");
#пишем в файл приготовленную строку
fwrite($file, $log_string, strlen($log_string));
#закрываем файл
fclose($file);
?>
? >