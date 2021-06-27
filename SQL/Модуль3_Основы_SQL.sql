--=============== МОДУЛЬ 3. ОСНОВЫ SQL =======================================
--= ПОМНИТЕ, ЧТО НЕОБХОДИМО УСТАНОВИТЬ ВЕРНОЕ СОЕДИНЕНИЕ И ВЫБРАТЬ СХЕМУ PUBLIC===========
SET search_path TO public;

--======== ОСНОВНАЯ ЧАСТЬ ==============

--ЗАДАНИЕ №1
--Выведите для каждого покупателя его адрес проживания, 
--город и страну проживания.
SELECT concat(c.first_name,' ',c.last_name) as "Фамилия и имя",
       a.address "Адресс",
       c2.city as "Город",
       c3.country as "Страна"
       FROM customer c
        join address a
          on c.address_id = a.address_id
        join city c2 on a.city_id = c2.city_id
        join country c3 on c2.country_id = c3.country_id;



--ЗАДАНИЕ №2
--С помощью SQL-запроса посчитайте для каждого магазина количество его покупателей.
SELECT c.store_id as "ID магазина",
       COUNT(DISTINCT c.customer_id) as "колличество покупателей"
FROM customer c
group by c.store_id
order by "колличество покупателей";




--Доработайте запрос и выведите только те магазины, 
--у которых количество покупателей больше 300-от.
--Для решения используйте фильтрацию по сгруппированным строкам 
--с использованием функции агрегации.
SELECT c.store_id as "ID магазина",
       COUNT(DISTINCT c.customer_id) as "колличество покупателей"
FROM customer c
group by c.store_id
Having COUNT(DISTINCT c.customer_id) > 300
order by "колличество покупателей";




-- Доработайте запрос, добавив в него информацию о городе магазина, 
--а также фамилию и имя продавца, который работает в этом магазине.
SELECT s1."ID магазина",
       s1."колличество покупателей",
       c2.city as "Город",
       concat(s.first_name,' ',s.last_name) as "Фамилия и имя"
       FROM staff s
        join address a on s.address_id = a.address_id
        join city c2 on a.city_id = c2.city_id
        join
                (SELECT c.store_id as "ID магазина",
                        COUNT(DISTINCT c.customer_id) as "колличество покупателей"
                 FROM customer c
                 group by c.store_id
                 Having COUNT(DISTINCT c.customer_id) > 300
                 order by "колличество покупателей") as s1 on s1."ID магазина"=s.store_id;


--ЗАДАНИЕ №3
--Выведите ТОП-5 покупателей, 
--которые взяли в аренду за всё время наибольшее количество фильмов
SELECT concat(c.first_name,' ',c.last_name) as "Фамилия и имя",
       f.activerent as "Количество фильмов"
FROM customer c
join
      (SELECT customer_id,
      COUNT(rental_id) as activerent
      FROM rental
      GROUP BY customer_id
      ORDER BY activerent
      DESC LIMIT 5) as f on f.customer_id = c.customer_id
GROUP BY "Фамилия и имя", f.activerent;




--ЗАДАНИЕ №4
--Посчитайте для каждого покупателя 4 аналитических показателя:
--  1. количество фильмов, которые он взял в аренду
--  2. общую стоимость платежей за аренду всех фильмов (значение округлите до целого числа)
--  3. минимальное значение платежа за аренду фильма
--  4. максимальное значение платежа за аренду фильма
SELECT concat(c.first_name,' ',c.last_name) as "Фамилия и имя",
       f.activerent as "Количество фильмов",
       round(sum(p.amount)) as "Общая стоимость платежей",
       min(p.amount) as "Минимальная стоимость платежа",
       max(p.amount) as "Максимальная стоимость платежа"
FROM customer c
join
      (SELECT customer_id,
      COUNT(rental_id) as activerent
      FROM rental
      GROUP BY customer_id) as f on f.customer_id = c.customer_id
join payment p on c.customer_id = p.customer_id
GROUP BY "Фамилия и имя", f.activerent;




--ЗАДАНИЕ №5
--Используя данные из таблицы городов составьте одним запросом всевозможные пары городов таким образом,
 --чтобы в результате не было пар с одинаковыми названиями городов. 
 --Для решения необходимо использовать декартово произведение.
 SELECT  c.city as City1,
        c2.city as City2
FROM city c, city c2
where c.city <> c2.city;

--ЗАДАНИЕ №6
--Используя данные из таблицы rental о дате выдачи фильма в аренду (поле rental_date)
--и дате возврата фильма (поле return_date), 
--вычислите для каждого покупателя среднее количество дней, за которые покупатель возвращает фильмы.
SELECT customer_id as "ID покупателя",
       ROUND(AVG(DATE(return_date) -DATE(rental_date)),2) as "Среднее количество дней возврата"
FROM rental
GROUP BY customer_id; 




--======== ДОПОЛНИТЕЛЬНАЯ ЧАСТЬ ==============

--ЗАДАНИЕ №1
--Посчитайте для каждого фильма сколько раз его брали в аренду и значение общей стоимости аренды фильма за всё время.





--ЗАДАНИЕ №2
--Доработайте запрос из предыдущего задания и выведите с помощью запроса фильмы, которые ни разу не брали в аренду.





--ЗАДАНИЕ №3
--Посчитайте количество продаж, выполненных каждым продавцом. Добавьте вычисляемую колонку "Премия".
--Если количество продаж превышает 7300, то значение в колонке будет "Да", иначе должно быть значение "Нет".







