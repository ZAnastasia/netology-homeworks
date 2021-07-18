--=============== МОДУЛЬ 4. УГЛУБЛЕНИЕ В SQL =======================================
--= ПОМНИТЕ, ЧТО НЕОБХОДИМО УСТАНОВИТЬ ВЕРНОЕ СОЕДИНЕНИЕ И ВЫБРАТЬ СХЕМУ PUBLIC===========
SET search_path TO public;

--======== ОСНОВНАЯ ЧАСТЬ ==============

--ЗАДАНИЕ №1
--База данных: если подключение к облачной базе, то создаете новые таблицы в формате:
--таблица_фамилия, 
--если подключение к контейнеру или локальному серверу, то создаете новую схему и в ней создаете таблицы.


-- Спроектируйте базу данных для следующих сущностей:
-- 1. язык (в смысле английский, французский и тп)
-- 2. народность (в смысле славяне, англосаксы и тп)
-- 3. страны (в смысле Россия, Германия и тп)


--Правила следующие:
-- на одном языке может говорить несколько народностей
-- одна народность может входить в несколько стран
-- каждая страна может состоять из нескольких народностей

 
--Требования к таблицам-справочникам:
-- идентификатор сущности должен присваиваться автоинкрементом
-- наименования сущностей не должны содержать null значения и не должны допускаться дубликаты в названиях сущностей
 
--СОЗДАНИЕ ТАБЛИЦЫ ЯЗЫКИ
CREATE TABLE language_AnastaciaZ (
  language_id serial PRIMARY KEY,
  language_name varchar(50) UNIQUE NOT NULL,
  create_date timestamp DEFAULT now()
);


--ВНЕСЕНИЕ ДАННЫХ В ТАБЛИЦУ ЯЗЫКИ
INSERT INTO language_AnastaciaZ (language_name)
VALUES('English'),
      ('Spanish'),
      ('Russian'),
      ('Polish'),
      ('Estonian');


--СОЗДАНИЕ ТАБЛИЦЫ НАРОДНОСТИ
CREATE TABLE nationality_AnastaciaZ (
  nationality_id serial PRIMARY KEY,
  nationality_name varchar(50) UNIQUE NOT NULL,
  create_date timestamp DEFAULT now()
);


--ВНЕСЕНИЕ ДАННЫХ В ТАБЛИЦУ НАРОДНОСТИ
INSERT INTO nationality_AnastaciaZ (nationality_name)
VALUES('Englishman'),
      ('Hispanic'),
      ('Russian'),
      ('Pole'),
      ('Estonian');


--СОЗДАНИЕ ТАБЛИЦЫ СТРАНЫ
CREATE TABLE country_AnastaciaZ (
  country_id serial PRIMARY KEY,
  country_name varchar(50) UNIQUE NOT NULL,
  create_date timestamp DEFAULT now()
);


--ВНЕСЕНИЕ ДАННЫХ В ТАБЛИЦУ СТРАНЫ
INSERT INTO country_AnastaciaZ (country_name)
VALUES('England'),
      ('Spain'),
      ('Russia'),
      ('Poland'),
      ('Estonia');


--СОЗДАНИЕ ПЕРВОЙ ТАБЛИЦЫ СО СВЯЗЯМИ
create table nationality_language_AnastaciaZ
(
  language_id    smallint                not null,
  nationality_id     smallint                not null,
  create_date timestamp DEFAULT now()
);


--ВНЕСЕНИЕ ДАННЫХ В ТАБЛИЦУ СО СВЯЗЯМИ
ALTER TABLE
nationality_language_AnastaciaZ ADD CONSTRAINT nationality_language_AnastaciaZ_language_id_fkey
FOREIGN KEY (language_id) REFERENCES language_AnastaciaZ (language_id);

ALTER TABLE
nationality_language_AnastaciaZ ADD CONSTRAINT nationality_language_AnastaciaZ_nationality_id_fkey
FOREIGN KEY (nationality_id) REFERENCES nationality_AnastaciaZ (nationality_id); 

ALTER TABLE
nationality_language_AnastaciaZ ADD CONSTRAINT nationality_language_pkey 
PRIMARY KEY (nationality_id,language_id); 

INSERT INTO nationality_language_AnastaciaZ (language_id, nationality_id)
VALUES('1','1'),
      ('2','2'),
      ('3','3'),
      ('4','4'),
      ('5','5'),
      ('1','5');


--СОЗДАНИЕ ВТОРОЙ ТАБЛИЦЫ СО СВЯЗЯМИ
create table nationality_country_AnastaciaZ
(
  nationality_id     smallint                not null,
  country_id    smallint                not null,
  create_date timestamp DEFAULT now()
);


--ВНЕСЕНИЕ ДАННЫХ В ТАБЛИЦУ СО СВЯЗЯМИ
ALTER TABLE
nationality_country_AnastaciaZ ADD CONSTRAINT nationality_country_AnastaciaZ_nationality_id_fkey
FOREIGN KEY (nationality_id) REFERENCES nationality_AnastaciaZ (nationality_id);


ALTER TABLE
nationality_country_AnastaciaZ ADD CONSTRAINT nationality_country_AnastaciaZ_country_id_fkey
FOREIGN KEY (country_id) REFERENCES country_AnastaciaZ (country_id);

ALTER TABLE
nationality_country_AnastaciaZ ADD CONSTRAINT nationality_country_pkey
PRIMARY KEY (nationality_id,country_id); 


INSERT INTO nationality_country_AnastaciaZ (nationality_id, country_id)
VALUES('1','1'),
      ('2','2'),
      ('3','3'),
      ('4','4'),
      ('5','5'),
      ('2','1');

--======== ДОПОЛНИТЕЛЬНАЯ ЧАСТЬ ==============


--ЗАДАНИЕ №1 
--Создайте новую таблицу film_new со следующими полями:
--·   	film_name - название фильма - тип данных varchar(255) и ограничение not null
--·   	film_year - год выпуска фильма - тип данных integer, условие, что значение должно быть больше 0
--·   	film_rental_rate - стоимость аренды фильма - тип данных numeric(4,2), значение по умолчанию 0.99
--·   	film_duration - длительность фильма в минутах - тип данных integer, ограничение not null и условие, что значение должно быть больше 0
--Если работаете в облачной базе, то перед названием таблицы задайте наименование вашей схемы.



--ЗАДАНИЕ №2 
--Заполните таблицу film_new данными с помощью SQL-запроса, где колонкам соответствуют массивы данных:
--·       film_name - array['The Shawshank Redemption', 'The Green Mile', 'Back to the Future', 'Forrest Gump', 'Schindlers List']
--·       film_year - array[1994, 1999, 1985, 1994, 1993]
--·       film_rental_rate - array[2.99, 0.99, 1.99, 2.99, 3.99]
--·   	  film_duration - array[142, 189, 116, 142, 195]



--ЗАДАНИЕ №3
--Обновите стоимость аренды фильмов в таблице film_new с учетом информации, 
--что стоимость аренды всех фильмов поднялась на 1.41



--ЗАДАНИЕ №4
--Фильм с названием "Back to the Future" был снят с аренды, 
--удалите строку с этим фильмом из таблицы film_new



--ЗАДАНИЕ №5
--Добавьте в таблицу film_new запись о любом другом новом фильме



--ЗАДАНИЕ №6
--Напишите SQL-запрос, который выведет все колонки из таблицы film_new, 
--а также новую вычисляемую колонку "длительность фильма в часах", округлённую до десятых



--ЗАДАНИЕ №7 
--Удалите таблицу film_new