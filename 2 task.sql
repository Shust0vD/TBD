--Однотабличные запросы
-- 1) Вывести всеми возможными способами имена и фамилии студентов, средний балл которых от 4 до 4.5
--SELECT name, surname FROM student WHERE score >= 4 AND score <= 4.5;

-- 2) Познакомиться с функцией CAST. Вывести при помощи неё студентов заданного курса (использовать Like)
--SELECT name, surname, n_group FROM student WHERE CAST(n_group AS varchar) LIKE '2%';

-- 3) Вывести всех студентов, отсортировать по убыванию номера группы и имени от а до я
--SELECT name, surname, n_group FROM student ORDER BY n_group DESC, name ASC;

-- 4) Вывести студентов, средний балл которых больше 4 и отсортировать по баллу от большего к меньшему
--SELECT name, surname, score FROM student WHERE score > 4 ORDER BY score DESC;

-- 5) Вывести на экран название и риск футбола и хоккея
--SElECT name, risk FROM hobby WHERE name = 'Football' OR name = 'Hockey';

-- 6) Вывести id хобби и id студента которые начали заниматься хобби между двумя заданными датами (выбрать самим) и студенты должны до сих пор заниматься хобби
--SELECT student_id, hobby_id FROM student_hobby WHERE started_at BETWEEN '2016-01-01'
--AND '2018-12-31' AND finished_at IS NULL;

-- 7) Вывести студентов, средний балл которых больше 4.5 и отсортировать по баллу от большего к меньшему
--SELECT name, surname, score FROM student WHERE score > 4.5 ORDER BY score DESC;

-- 8) Из запроса №7 вывести несколькими способами на экран только 5 студентов с максимальным баллом
--SELECT name, surname, score FROM student WHERE score > 4.5 ORDER BY score DESC LIMIT 5;

/* 9) Выведите хобби и с использованием условного оператора сделайте риск словами:

>=8 - очень высокий
>=6 & <8 - высокий
>=4 & <8 - средний
>=2 & <4 - низкий
<2 - очень низкий */
/*SELECT name, risk, CASE
 WHEN risk < 2 THEN 'очень низкий'
 WHEN risk >= 2 AND risk < 4 THEN 'низкий'
 WHEN risk >= 4 AND risk < 6 THEN 'средний'
 WHEN risk >= 6 AND risk < 8 THEN 'высокий'
 WHEN risk >= 8 THEN 'очень высокий'
 END
 FROM hobby;*/
 
 -- 10) Вывести 3 хобби с максимальным риском
--SELECT name, risk FROM hobby ORDER BY risk DESC LIMIT 3;

--Групповые функции
-- 1) Выведите на экран номера групп и количество студентов, обучающихся в них
--SELECT n_group, COUNT(n_group) AS stud_count FROM student GROUP BY n_group ORDER BY n_group DESC;

-- 2) Выведите на экран для каждой группы максимальный средний балл
--SELECT n_group, MAX(score) AS max_score FROM student GROUP BY n_group ORDER BY n_group DESC;

-- 3) Подсчитать количество студентов с каждой фамилией
--SELECT surname, COUNT(surname) AS surname_count FROM student GROUP BY surname;

-- 4) Подсчитать студентов, которые родились в каждом году
--SELECT date_birth, COUNT(date_birth) AS date_count FROM student GROUP BY date_birth;

-- 5) Для студентов каждого курса подсчитать средний балл см. Substr
/*SELECT substr(CAST(n_group AS varchar), 1, 1), AVG(score) AS avg_score 
FROM student GROUP BY substr(CAST(n_group AS varchar), 1, 1) 
ORDER BY substr(CAST(n_group AS varchar), 1, 1);*/

-- 6) Для студентов заданного курса вывести один номер группы с максимальным средним баллом
/*SELECT n_group, AVG(score) AS avg_score 
FROM student WHERE CAST(n_group AS varchar) LIKE '2%' GROUP BY n_group 
ORDER BY avg_score DESC LIMIT 1;*/

-- 7) Для каждой группы подсчитать средний балл, вывести на экран только те номера групп и их средний балл, в которых он менее или равен 3.5. Отсортировать по от меньшего среднего балла к большему.
/*SELECT n_group, AVG(score) AS avg_score 
FROM student GROUP BY n_group HAVING AVG(score) <= 3.5
ORDER BY avg_score ASC;*/

-- 8) Для каждой группы в одном запросе вывести количество студентов, максимальный балл в группе, средний балл в группе, минимальный балл в группе
/*SELECT n_group, COUNT(n_group) AS stud_count, MAX(score) AS max_score, AVG(score) AS avg_score,
MIN(score) AS min_score FROM student GROUP BY n_group ORDER BY n_group DESC;*/

-- 9) Вывести студента/ов, который/ые имеют наибольший балл в заданной группе
/*SELECT id, surname, n_group, score FROM student WHERE 
score = (SELECT MAX(score) FROM student WHERE n_group = 3081 GROUP BY n_group);*/

-- 10) Аналогично 9 заданию, но вывести в одном запросе для каждой группы студента с максимальным баллом.
/*SELECT st.id, st.surname, st.n_group, st.score 
FROM student st, (SELECT n_group, MAX(score) as score FROM student GROUP BY n_group) as maxx
WHERE st.n_group = maxx.n_group AND st.score = maxx.score
ORDER BY st.n_group;*/
