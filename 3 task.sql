--Многотабличные запросы

--1) Вывести все имена и фамилии студентов, и название хобби, которым занимается этот студент.
/*SELECT st.name,
	st.surname,
	hobby.name
FROM student st, hobby, student_hobby sh
WHERE st.id = sh.student_id AND hobby.id = sh.hobby_id;*/

--2) Вывести информацию о студенте, занимающимся хобби самое продолжительное время.
/*SELECT st.id,
	st.name,
	st.surname,
	hobby.name,
	age(sh.finished_at, sh.started_at) AS term
FROM student st, hobby, student_hobby sh
WHERE st.id = sh.student_id AND hobby.id = sh.hobby_id
AND age(sh.finished_at, sh.started_at) is NOT null
ORDER BY term DESC
LIMIT 1;*/

--3) Вывести имя, фамилию, номер зачетки и дату рождения для студентов, средний балл которых выше среднего, а сумма риска --всех хобби, которыми он занимается в данный момент, больше 0.9.
/*SELECT st.id,
	st.name,
	st.surname,
	st.date_birth,
	st.score,
	SUM(hobby.risk) AS sum_risk
FROM student st
INNER JOIN student_hobby sh ON st.id = sh.student_id
INNER JOIN hobby ON hobby.id = sh.hobby_id
WHERE st.score > (SELECT SUM(score)/COUNT(score) FROM student)
GROUP BY st.id
HAVING SUM(hobby.risk) > 9;*/

--4) Вывести фамилию, имя, зачетку, дату рождения, название хобби и длительность в месяцах, для всех завершенных хобби
/*SELECT st.id,
	st.name,
	st.surname,
	st.date_birth,
	hobby.name AS name_hobby,
	12*extract(year from age(sh.finished_at, sh.started_at)) AS months
FROM student st
INNER JOIN student_hobby sh ON st.id = sh.student_id
INNER JOIN hobby ON hobby.id = sh.hobby_id
WHERE age(sh.finished_at, sh.started_at) is NOT null;*/

--5) Вывести фамилию, имя, зачетку, дату рождения студентов, которым исполнилось N полных лет на текущую дату, и которые --имеют более 1 действующего хобби.
/*SELECT st.id,
	st.name,
	st.surname,
	st.date_birth,
	extract(year from age(current_date, st.date_birth)) AS years
FROM student st
INNER JOIN student_hobby sh ON st.id = sh.student_id
INNER JOIN hobby ON hobby.id = sh.hobby_id
WHERE extract(year from age(current_date, st.date_birth)) > 19
AND (SELECT COUNT(hobby.name) FROM hobby WHERE sh.finished_at is null) > 1
GROUP BY st.id;*/

--6) Найти средний балл в каждой группе, учитывая только баллы студентов, которые имеют хотя бы одно действующее хобби.
/*SELECT st.n_group,
	round(AVG(score), 2)
FROM student st
INNER JOIN student_hobby sh ON st.id = sh.student_id
INNER JOIN hobby ON hobby.id = sh.hobby_id
WHERE (SELECT COUNT(hobby.name) FROM hobby WHERE sh.finished_at is null) >= 1
GROUP BY st.n_group;*/

--7) Найти название, риск, длительность в месяцах самого продолжительного хобби из действующих, указав номер зачетки --студента.
/*SELECT st.id AS student_id,
	hobby.name,
	hobby.risk,
	12*extract(year from age(current_date, sh.started_at)) AS months
FROM student st
INNER JOIN student_hobby sh ON st.id = sh.student_id
INNER JOIN hobby ON hobby.id = sh.hobby_id
WHERE sh.finished_at is null
ORDER BY months DESC
LIMIT 1;*/

--8) Найти все хобби, которыми увлекаются студенты, имеющие максимальный балл.
/*SELECT hobby.name
FROM hobby
INNER JOIN student_hobby sh ON hobby.id = sh.hobby_id
INNER JOIN student st ON st.id = sh.student_id
WHERE st.score = (SELECT MAX(score) FROM student) AND sh.finished_at IS null;*/

--9) Найти все действующие хобби, которыми увлекаются троечники 2-го курса.
/*SELECT hobby.name
FROM hobby
INNER JOIN student_hobby sh ON hobby.id = sh.hobby_id
INNER JOIN student st ON st.id = sh.student_id
WHERE st.score < 4 AND sh.finished_at IS null AND CAST(st.n_group AS varchar) LIKE '2%';*/

--10) Найти номера курсов, на которых более 50% студентов имеют более одного действующего хобби.
/*SELECT course_act.course
FROM
(SELECT course, COUNT(DISTINCT sh.student_id )as zanim
FROM student_hobby sh
INNER JOIN (
SELECT DISTINCT n_group/1000 as course, st.id
FROM student st) as nt on nt.id = sh.student_id
WHERE finished_at IS NULL
GROUP BY course) as course_act
RIGHT JOIN
(SELECT n_group/1000 as course, COUNT(*) from student st GROUP BY n_group/1000) as course_all
on course_act.course = course_all.course
WHERE course_act.zanim*1./course_all.count>0.5;*/

--11) Вывести номера групп, в которых не менее 60% студентов имеют балл не ниже 4.
/*SELECT st1.n_group
FROM (SELECT n_group, COUNT(id) FROM student WHERE score >= 4 GROUP BY n_group) AS st1
INNER JOIN (SELECT n_group, COUNT(id) FROM student GROUP BY n_group) AS st2
ON st1.n_group = st2.n_group
WHERE st2.count/st1.count >= 0.6;*/

--12) Для каждого курса подсчитать количество различных действующих хобби на курсе.
/*SELECT st.n_group/1000 as course, COUNT(DISTINCT h.id)
FROM student st
INNER JOIN student_hobby sh
ON sh.student_id = st.id
INNER JOIN hobby h
ON sh.hobby_id = h.id
WHERE sh.finished_at IS null
GROUP BY course;*/

--13) Вывести номер зачётки, фамилию и имя, дату рождения и номер курса для всех отличников, не имеющих хобби. Отсортировать данные по возрастанию в пределах курса по убыванию даты рождения.
/*SELECT st.id as n_zach, st.surname, st.name, st.date_birth, st.n_group/1000 as course
FROM student st
LEFT JOIN (SELECT sh.student_id as st_id FROM student_hobby sh GROUP BY st_id
		   HAVING COUNT(sh.started_at) = COUNT(sh.finished_at)) as shh
ON shh.st_id = st.id
WHERE st.score = 5
ORDER BY course ASC, st.date_birth DESC;*/

--14) Создать представление, в котором отображается вся информация о студентах, которые продолжают заниматься хобби в данный момент и занимаются им как минимум 5 лет.
/*CREATE OR REPLACE VIEW sh_more5 AS
SELECT st.* FROM student st
INNER JOIN student_hobby sh
ON st.id = sh.student_id
WHERE sh.finished_at IS null AND current_date-sh.started_at > 1825;
SELECT * FROM sh_more5;*/

--15) Для каждого хобби вывести количество людей, которые им занимаются.
/*SELECT h.name, COUNT(DISTINCT sh.student_id)
FROM hobby h
INNER JOIN student_hobby sh
ON sh.hobby_id = h.id
GROUP BY h.name;*/

--16) Вывести ИД самого популярного хобби.
/*SELECT sh.hobby_id
FROM student_hobby sh
GROUP BY sh.hobby_id
ORDER BY COUNT(sh.student_id) DESC
LIMIT 1;*/

--17) Вывести всю информацию о студентах, занимающихся самым популярным хобби.
/*SELECT st.*
FROM student st
INNER JOIN student_hobby sh
ON st.id = sh.student_id
WHERE sh.hobby_id =
	(SELECT sh.hobby_id
	FROM student_hobby sh
	GROUP BY sh.hobby_id
	ORDER BY COUNT(sh.student_id) DESC
	LIMIT 1);*/

--18) Вывести ИД 3х хобби с максимальным риском.
/*SELECT h.id
FROM hobby h
ORDER BY h.risk DESC
LIMIT 3;*/

--19) Вывести 10 студентов, которые занимаются одним (или несколькими) хобби самое продолжительно время.
/*SELECT st.id,
	st.name,
	st.surname,
	age(current_date, sh.started_at) AS term
FROM student st
INNER JOIN student_hobby sh
ON st.id = sh.student_id
WHERE sh.finished_at IS null
ORDER BY term DESC
LIMIT 10;*/

--20) Вывести номера групп (без повторений), в которых учатся студенты из предыдущего запроса.
/*SELECT DISTINCT prev.n_group
FROM(SELECT st.id,
		st.name,
		st.surname,
	 	st.n_group,
		age(current_date, sh.started_at) AS term
	FROM student st
	INNER JOIN student_hobby sh
	ON st.id = sh.student_id
	WHERE sh.finished_at IS null
	ORDER BY term DESC
	LIMIT 10) AS prev*/

--21) Создать представление, которое выводит номер зачетки, имя и фамилию студентов, отсортированных по убыванию среднего балла.
/*CREATE OR REPLACE VIEW desc_score AS
SELECT st.id, st.name, st.surname
FROM student st
ORDER BY st.score DESC;
SELECT * FROM desc_score;*/

--22) Представление: найти каждое популярное хобби на каждом курсе.
/*CREATE OR REPLACE VIEW hobby_course AS
SELECT DISTINCT ON (1) st.n_group/1000 AS crs, h.name
FROM student st
INNER JOIN student_hobby sh
ON st.id = sh.student_id
INNER JOIN hobby h
ON h.id = sh.hobby_id
GROUP BY crs, h.name
ORDER BY crs, COUNT(h.name) DESC;
SELECT * FROM hobby_course;*/

--23) Представление: найти хобби с максимальным риском среди самых популярных хобби на 2 курсе.
/*CREATE OR REPLACE VIEW smth AS
SELECT st.n_group/1000 AS crs, h.name, h.risk
FROM student st
INNER JOIN student_hobby sh
ON st.id = sh.student_id
INNER JOIN hobby h
ON h.id = sh.hobby_id
WHERE st.n_group/1000 = 2
GROUP BY crs, h.name, h.risk
ORDER BY h.risk DESC
LIMIT 1;
SELECT * FROM smth;*/

--24) Представление: для каждого курса подсчитать количество студентов на курсе и количество отличников.
/*CREATE OR REPLACE VIEW crs_count AS
SELECT st.n_group/1000 AS crs, COUNT(st.id) AS total,
COUNT(st.id) FILTER (WHERE st.score = 5) AS excellent
FROM student st
GROUP BY crs
ORDER BY crs ASC;
SELECT * FROM crs_count;*/

--25) Представление: самое популярное хобби среди всех студентов.
/*CREATE OR REPLACE VIEW hobby_popular AS
SELECT h.name, COUNT(sh.hobby_id)
FROM student_hobby sh
INNER JOIN hobby h
ON h.id = sh.hobby_id
GROUP BY h.name
ORDER BY count DESC
LIMIT 1;
SELECT * FROM hobby_popular;*/

--26) Создать обновляемое представление.
/*CREATE OR REPLACE VIEW student_view AS
SELECT * FROM student
ORDER BY id;
SELECT * FROM student_view;*/

--27) Для каждой буквы алфавита из имени найти максимальный, средний и минимальный балл. (Т.е. среди всех студентов, чьё имя начинается на А (Алексей, Алина, Артур, Анджела) найти то, что указано в задании. Вывести на экран тех, максимальный балл которых больше 3.6
/*SELECT substr(st.name, 1, 1) AS f_let, MAX(st.score), ROUND(AVG(st.score), 2) AS avg, MIN(st.score)
FROM student st
GROUP BY f_let
HAVING MAX(st.score) > 3.6
ORDER BY f_let;*/

--28) Для каждой фамилии на курсе вывести максимальный и минимальный средний балл. (Например, в университете учатся 4 Иванова (1-2-3-4). 1-2-3 учатся на 2 курсе и имеют средний балл 4.1, 4, 3.8 соответственно, а 4 Иванов учится на 3 курсе и имеет балл 4.5. На экране должно быть следующее: 2 Иванов 4.1 3.8 3 Иванов 4.5 4.5
/*SELECT st.n_group/1000 AS course, st.name, MAX(st.score), MIN(st.score)
FROM student st
GROUP BY course, st.name
ORDER BY course;*/

--29) Для каждого года рождения подсчитать количество хобби, которыми занимаются или занимались студенты.
/*SELECT EXTRACT(year FROM st.date_birth) AS year, COUNT(DISTINCT sh.hobby_id)
FROM student st
INNER JOIN student_hobby sh
ON st.id = sh.student_id
GROUP BY year;*/

--30) Для каждой буквы алфавита в имени найти максимальный и минимальный риск хобби.
/*SELECT substr(st.name, 1, 1) AS f_let, MAX(h.risk), MIN(h.risk)
FROM student st
INNER JOIN student_hobby sh
ON st.id = sh.student_id
INNER JOIN hobby h
ON h.id = sh.hobby_id
GROUP BY f_let
ORDER BY f_let;*/

--31) Для каждого месяца из даты рождения вывести средний балл студентов, которые занимаются хобби с названием «Футбол»
