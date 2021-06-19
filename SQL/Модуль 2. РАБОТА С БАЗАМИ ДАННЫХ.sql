--=============== МОДУЛЬ 2. РАБОТА С БАЗАМИ ДАННЫХ =======================================
--= ПОМНИТЕ, ЧТО НЕОБХОДИМО УСТАНОВИТЬ ВЕРНОЕ СОЕДИНЕНИЕ И ВЫБРАТЬ СХЕМУ PUBLIC===========
SET search_path TO public;

--======== ОСНОВНАЯ ЧАСТЬ ==============

--ЗАДАНИЕ №1
--Выведите уникальные названия регионов из таблицы адресов
SELECT DISTINCT district FROM address;

--Aden
--Eastern Visayas
--Vaduz
--Tokat
--Anzotegui
--Saint-Denis
--Chollanam
--Chihuahua
--Nyanza
--Changhwa
--Tokyo-to
--Santa F
--Denizli
--Noord-Brabant
--Hubei
--Zulia
--Paran
--Mwanza
--Nova Scotia
--Caraga

--всего 378 строк




--ЗАДАНИЕ №2
--Доработайте запрос из предыдущего задания, чтобы запрос выводил только те регионы, 
--названия которых начинаются на "K" и заканчиваются на "a", и названия не содержат пробелов
SELECT DISTINCT district FROM address
where district LIKE'K%' and district LIKE'%a' and district NOT LIKE'% %';

--Kaduna
--Kalmykia
--Kanagawa
--Karnataka
--Kerala
--Kitaa
--Ktahya





--ЗАДАНИЕ №3
--Получите из таблицы платежей за прокат фильмов информацию по платежам, которые выполнялись 
--в промежуток с 17 марта 2007 года по 19 марта 2007 года включительно, 
--и стоимость которых превышает 1.00.
--Платежи нужно отсортировать по дате платежа.
SELECT payment_id, payment_date, amount FROM payment
where payment_date between '2007-03-17' and '2007-03-20'
      and amount > 1.0
order by payment_date;

--20228,2007-03-17 00:02:58.996577
--19799,2007-03-17 00:06:17.996577
--21870,2007-03-17 00:06:21.996577
--24068,2007-03-17 00:06:44.996577
--19770,2007-03-17 00:21:46.996577
--22548,2007-03-17 00:22:39.996577
--20340,2007-03-17 00:26:15.996577
--21109,2007-03-17 00:27:33.996577
--24814,2007-03-17 00:31:28.996577
--20178,2007-03-17 00:32:15.996577





--ЗАДАНИЕ №4
-- Выведите информацию о 10-ти последних платежах за прокат фильмов.
SELECT payment_id, payment_date, amount FROM payment
order by payment_date DESC LIMIT 10;

--31925,2007-05-14 13:44:29.996577,0.00
--31923,2007-05-14 13:44:29.996577,0.99
--31922,2007-05-14 13:44:29.996577,4.99
--31924,2007-05-14 13:44:29.996577,5.98
--31921,2007-05-14 13:44:29.996577,0.99
--31917,2007-05-14 13:44:29.996577,7.98
--31920,2007-05-14 13:44:29.996577,0.00
--31918,2007-05-14 13:44:29.996577,0.00
--31919,2007-05-14 13:44:29.996577,3.98
--31926,2007-05-14 13:44:29.996577,0.99





--ЗАДАНИЕ №5
--Выведите следующую информацию по покупателям:
--  1. Фамилия и имя (в одной колонке через пробел)
--  2. Электронная почта
--  3. Длину значения поля email
--  4. Дату последнего обновления записи о покупателе (без времени)
--Каждой колонке задайте наименование на русском языке.
SELECT concat(first_name,' ',last_name) as "Фамилия и имя",
       email as "Электронная почта",
       character_length(email)  as "Длинна строки",
       DATE(last_update) as "Дата"
       FROM customer;



--ЗАДАНИЕ №6
--Выведите одним запросом активных покупателей, имена которых Kelly или Willie.
--Все буквы в фамилии и имени из нижнего регистра должны быть переведены в высокий регистр.
SELECT upper(last_name), upper(first_name), active FROM customer
where upper(first_name) = 'KELLY' or upper(first_name) = 'WILLIE' and active = 1;




--======== ДОПОЛНИТЕЛЬНАЯ ЧАСТЬ ==============

--ЗАДАНИЕ №1
--Выведите одним запросом информацию о фильмах, у которых рейтинг "R" 
--и стоимость аренды указана от 0.00 до 3.00 включительно, 
--а также фильмы c рейтингом "PG-13" и стоимостью аренды больше или равной 4.00.





--ЗАДАНИЕ №2
--Получите информацию о трёх фильмах с самым длинным описанием фильма.





--ЗАДАНИЕ №3
-- Выведите Email каждого покупателя, разделив значение Email на 2 отдельных колонки:
--в первой колонке должно быть значение, указанное до @, 
--во второй колонке должно быть значение, указанное после @.





--ЗАДАНИЕ №4
--Доработайте запрос из предыдущего задания, скорректируйте значения в новых колонках: 
--первая буква должна быть заглавной, остальные строчными.




